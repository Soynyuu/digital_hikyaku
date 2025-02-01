from bcrypt import hashpw, gensalt
from datetime import datetime, timedelta
from flask import Flask, abort, jsonify, request, session
from flask_cors import CORS
from os import urandom
from string import ascii_letters, digits, punctuation
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from ulid import ULID
from werkzeug.exceptions import HTTPException
from waitress import serve
from config import SECRET_KEY

app = Flask(__name__)
# app.secret_key = urandom(16)
app.secret_key = SECRET_KEY

CORS(
    app,
    supports_credentials=True,
    origins="*",  # すべてのオリジンを許可
    allow_headers=["Content-Type"],
    expose_headers=["Set-Cookie"],
)

app.config.update(
    SESSION_COOKIE_SAMESITE="None",
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_DOMAIN=None,  # ドメイン制限を解除
)

dbpath = "database.db"

engine = create_engine(f"sqlite:///{dbpath}")


def init_db():
    with open("schema.sql") as f:
        src = f.read()

    with Session(engine) as DBsession:
        for stmt in src.split(";"):
            stmt = stmt.strip()
            if stmt:
                DBsession.execute(text(stmt))
        DBsession.commit()
        DBsession.close()


@app.route("/api/register", methods=["POST"])
def register():
    try:
        data = request.json
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    try:
        name = data.get("name")
        display_name = data.get("display_name")
        password = data.get("password")
        user_latitude = data.get("user_latitude")
        user_longitude = data.get("user_longitude")
        # email = data.get("email")
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    # 型
    if not isinstance(name, str):
        return jsonify({"error": "ユーザIDは文字列である必要があります"}), 400
    if not isinstance(display_name, str):
        return jsonify({"error": "ユーザ名は文字列である必要があります"}), 400
    if not isinstance(password, str):
        return jsonify({"error": "パスワードは文字列である必要があります"}), 400
    if not isinstance(user_latitude, float) and not isinstance(user_latitude, int):
        return jsonify({"error": "緯度は実数である必要があります"}), 400
    if not isinstance(user_longitude, float) and not isinstance(user_longitude, int):
        return jsonify({"error": "経度は実数である必要があります"}), 400

    # データ
    name_allowed_chars = ascii_letters + digits + "_"
    if not all(c in name_allowed_chars for c in name):
        return (
            jsonify(
                {"error": "ユーザ ID には英数字とアンダースコアのみを使用できます"}
            ),
            400,
        )
    if len(name) > 30:
        return jsonify({"error": "ユーザ ID は 30 文字以下である必要があります"}), 400

    if len(display_name) > 30 or len(display_name.encode("utf-8")) > 120:
        return jsonify({"error": "ユーザ名は 30 文字以下である必要があります"}), 400

    password_allowed_chars = ascii_letters + digits + punctuation
    if len(password) < 8:
        return jsonify({"error": "パスワードは 8 文字以上である必要があります"}), 400
    if not all(c in password_allowed_chars for c in password):
        return (
            jsonify({"error": "パスワードには英数字と記号のみを使用できます"}),
            400,
        )

    hashed_password = hashpw(password.encode(), gensalt(10))

    with Session(engine) as DBsession:
        try:
            try:
                DBsession.execute(
                    text(
                        "INSERT INTO users (id, name, display_name, password_hash, user_latitude, user_longitude) VALUES (:id, :name, :display_name, :password_hash, :user_latitude, :user_longitude)"
                    ),
                    {
                        "id": str(ULID()),
                        "name": name,
                        "display_name": display_name,
                        "password_hash": hashed_password,
                        "user_latitude": user_latitude,
                        "user_longitude": user_longitude,
                    },
                )
            except IntegrityError as e:
                print(e)
                DBsession.rollback()
                return jsonify({"error": "ユーザ ID が既に使用されています"}), 400
            DBsession.commit()
        except Exception as e:
            DBsession.rollback()
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    return jsonify({"message": "登録が完了しました"})


@app.route("/api/login", methods=["POST"])
def login():
    try:
        data = request.json
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    try:
        name = data.get("name")
        password = data.get("password")
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    # 型
    if not isinstance(name, str):
        return jsonify({"error": "ユーザ ID は文字列である必要があります"}), 400
    if not isinstance(password, str):
        return jsonify({"error": "パスワードは文字列である必要があります"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text("SELECT id, password_hash FROM users WHERE name = :name"),
                {"name": name},
            )

            row = res.fetchone()
            if row is None:
                return (
                    jsonify({"error": "ユーザー名またはパスワードが間違っています"}),
                    400,
                )

            hashed_password = row[1]
            if not hashpw(password.encode(), hashed_password) == hashed_password:
                return (
                    jsonify({"error": "ユーザー名またはパスワードが間違っています"}),
                    400,
                )

        except Exception as e:
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    session.permanent = True
    session["user_id"] = row[0]
    return jsonify({"message": "ログインに成功しました"})


@app.route("/api/logout", methods=["POST"])
def logout():
    session.pop("user_id", None)
    return jsonify({"message": "ログアウトしました"})


@app.route("/api/me", methods=["GET"])
def me():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text("SELECT id, name, display_name FROM users WHERE id = :id"),
                {"id": userid},
            )

            row = res.fetchone()
            if row is None:
                return jsonify({"error": "ユーザーが存在しません"}), 400

        except Exception as e:
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    return jsonify({"id": row[0], "name": row[1], "display_name": row[2]})


@app.route("/api/search-user", methods=["GET"])
def search_user():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    q = request.args.get("q")
    if not q:
        return jsonify({"error": "検索クエリを指定してください"}), 400

    if not isinstance(q, str):
        return jsonify({"error": "検索クエリは文字列である必要があります"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text(
                    "SELECT id, name, display_name FROM users WHERE name LIKE ('%' || :q || '%')"
                ),
                {"q": q},
            )

            row = res.fetchall()

        except Exception as e:
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    res = []
    for r in row:
        res.append({"id": r[0], "name": r[1], "display_name": r[2]})
    return jsonify(res)


@app.route("/api/relationship/new", methods=["POST"])
def new_relationship():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    try:
        data = request.json
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    try:
        target_id = data.get("target_id")
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    if not isinstance(target_id, str):
        return jsonify({"error": "ユーザ ID は文字列である必要があります"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text("SELECT id FROM users WHERE id = :id"), {"id": target_id}
            )
            if res.fetchone() is None:
                return jsonify({"error": "ユーザーが存在しません"}), 400

            try:
                DBsession.execute(
                    text(
                        "INSERT INTO relationships (id, sender_id, recipient_id, status) VALUES (:id, :user_id, :target_id, 'created')"
                    ),
                    {"id": str(ULID()), "user_id": userid, "target_id": target_id},
                )
            except IntegrityError as e:
                DBsession.rollback()
                return jsonify({"error": "既に登録されています"}), 400

            DBsession.commit()
        except Exception as e:
            DBsession.rollback()
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    return jsonify({"message": "成功しました"})


@app.route("/api/relationship/list", methods=["GET"])
def list_relationship():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text(
                    "SELECT id, sender_id, recipient_id, status FROM relationships WHERE sender_id = :id"  # OR recipient_id = :id
                ),
                {"id": userid},
            )

            row = res.fetchall()

            res = []
            for r in row:
                sender_name, sender_display_name = DBsession.execute(
                    text("SELECT name, display_name FROM users WHERE id = :id"),
                    {"id": r[1]},
                ).fetchone()
                recipient_name, recipient_display_name = DBsession.execute(
                    text("SELECT name, display_name FROM users WHERE id = :id"),
                    {"id": r[2]},
                ).fetchone()
                res.append(
                    {
                        "id": r[0],
                        "sender_id": r[1],
                        "recipient_id": r[2],
                        "status": r[3],
                        "sender_name": sender_name,
                        "sender_display_name": sender_display_name,
                        "recipient_name": recipient_name,
                        "recipient_display_name": recipient_display_name,
                    }
                )
        except Exception as e:
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    return jsonify(res)


@app.route("/api/letter/new", methods=["POST"])
def new_letter():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    try:
        data = request.json
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    try:
        target_id = data.get("target_id")
        content = data.get("content")
        letter_set_id = data.get("letter_set_id")
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    if not isinstance(target_id, str):
        return jsonify({"error": "ユーザ ID は文字列である必要があります"}), 400
    if not isinstance(content, str):
        return jsonify({"error": "メッセージは文字列である必要があります"}), 400
    if not isinstance(letter_set_id, str):
        return jsonify({"error": "レターセット ID は文字列である必要があります"}), 400

    if len(content) > 10000 or len(content.encode("utf-8")) > 50000:
        return (
            jsonify({"error": "メッセージは 10000 文字以下である必要があります"}),
            400,
        )

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text(
                    "SELECT id, user_latitude, user_longitude FROM users WHERE id = :id"
                ),
                {"id": userid},
            )
            sender = res.fetchone()
            if sender is None:
                return jsonify({"error": "ユーザーが存在しません"}), 400

            res = DBsession.execute(
                text(
                    "SELECT id, user_latitude, user_longitude FROM users WHERE id = :id"
                ),
                {"id": target_id},
            )
            recipient = res.fetchone()
            if recipient is None:
                return jsonify({"error": "ユーザーが存在しません"}), 400

            dis = (
                (sender[1] - recipient[1]) ** 2 + (sender[2] - recipient[2]) ** 2
            ) ** 0.5  # 単位: 度
            dis_km = dis * 111  # 単位: km
            # dis_hour = dis_km / 7  # 単位: 時間
            dis_hour = dis_km / 150  # 単位: 時間 デモ用に爆速

            DBsession.execute(
                text(
                    "INSERT INTO letters (id, sender_id, recipient_id, content, arrive_at, letter_set_id) VALUES (:id, :user_id, :target_id, :content, DATETIME('now',:arrive_at_diff), :letter_set_id)"
                ),
                {
                    "id": str(ULID()),
                    "user_id": userid,
                    "target_id": target_id,
                    "content": content,
                    "arrive_at_diff": f"{int(timedelta(hours=dis_hour).total_seconds())} seconds",
                    "letter_set_id": letter_set_id,
                },
            )

            DBsession.commit()
        except Exception as e:
            DBsession.rollback()
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    return jsonify({"message": "成功しました"})


@app.route("/api/letter/send_history", methods=["GET"])
def send_history():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text(
                    "SELECT id, sender_id, recipient_id, arrive_at, read_flag, created_at, letter_set_id FROM letters WHERE sender_id = :id"
                ),
                {"id": userid},
            )

            row = res.fetchall()
            res = []
            for r in row:
                sender_name = DBsession.execute(
                    text("SELECT name, display_name FROM users WHERE id = :id"),
                    {"id": r[1]},
                ).fetchone()

                recipient_name = DBsession.execute(
                    text("SELECT name, display_name FROM users WHERE id = :id"),
                    {"id": r[2]},
                ).fetchone()

                res.append(
                    {
                        "id": r[0],
                        "sender_id": r[1],
                        "sender_name": sender_name[0],
                        "recipient_id": r[2],
                        "recipient_name": recipient_name[0],
                        "arrive_at": r[3],
                        "read_flag": r[4],
                        "created_at": r[5],
                        "letter_set_id": r[6],
                    }
                )

        except Exception as e:
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    return jsonify(res)


@app.route("/api/letter/receive_history", methods=["GET"])
def receive_history():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    with Session(engine) as DBsession:
        try:
            now = datetime.now()
            res = DBsession.execute(
                text(
                    """
                    SELECT 
                        letters.id,
                        letters.sender_id,
                        letters.recipient_id,
                        letters.arrive_at,
                        letters.read_flag,
                        letters.created_at,
                        letters.letter_set_id,
                        sender.name as sender_name,
                        recipient.name as recipient_name
                    FROM letters 
                    JOIN users as sender ON letters.sender_id = sender.id
                    JOIN users as recipient ON letters.recipient_id = recipient.id
                    WHERE letters.recipient_id = :id
                    """
                ),
                {"id": userid},
            )

            row = res.fetchall()
            res = []
            for r in row:
                res.append(
                    {
                        "id": r[0],
                        "sender_id": r[1],
                        "recipient_id": r[2],
                        "arrive_at": 1 if r[3] <= now else 0,  # datetime比較の結果をint型で返す
                        "read_flag": r[4],
                        "created_at": r[5],
                        "letter_set_id": r[6],
                        "sender_name": r[7],
                        "recipient_name": r[8],
                    }
                )

            return jsonify(res)

        except Exception as e:
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()


@app.route("/api/letter/read", methods=["POST"])
def read_letter():
    userid = session.get("user_id")
    if not userid:
        return jsonify({"error": "ログインしてください"}), 400

    try:
        data = request.json
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    try:
        letter_id = data.get("letter_id")
    except Exception as e:
        app.logger.exception(e)
        return jsonify({"error": "リクエストが不正です"}), 400

    if not isinstance(letter_id, str):
        return jsonify({"error": "メッセージ ID は文字列である必要があります"}), 400

    with Session(engine) as DBsession:
        try:
            res = DBsession.execute(
                text(
                    "SELECT content, arrive_at, letter_set_id FROM letters WHERE id = :id AND recipient_id = :user_id"
                ),
                {"id": letter_id, "user_id": userid},
            )
            res = res.fetchone()
            if res is None:
                return jsonify({"error": "メッセージが存在しません"}), 400

            DBsession.execute(
                text("UPDATE letters SET read_flag = 1 WHERE id = :id"),
                {"id": letter_id},
            )

            DBsession.commit()
        except Exception as e:
            DBsession.rollback()
            app.logger.exception(e)
            return jsonify({"error": "内部エラーが発生しました"}), 500
        finally:
            DBsession.close()

    arrive_at = datetime.strptime(res[1], "%Y-%m-%d %H:%M:%S.%f")
    if arrive_at > datetime.now():
        return jsonify({"error": "メッセージはまだ開封できません"}), 400

    return jsonify({"content": res[0], "letter_set_id": res[2]})


if __name__ == "__main__":
    init_db()
    # app.run(host="0.0.0.0", port=1080, debug=True)
    serve(app, host="0.0.0.0", port=5000)