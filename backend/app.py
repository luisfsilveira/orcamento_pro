from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Configurações do seu PostgreSQL existente
DB_CONFIG = {
    "host": "localhost", # Ou o nome do serviço no Docker
    "database": "orcamento_pro",
    "user": "postgres",
    "password": "sua_senha_aqui"
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

@app.route('/alertas/vencimento', methods=['GET'])
def verificar_vencimentos():
    conn = get_db_connection()
    cur = conn.cursor()
    hoje = datetime.now().strftime('%Y-%m-%d')
    
    # Busca orçamentos pendentes que vencem hoje ou já venceram
    cur.execute("""
        SELECT o.id, c.nome, o.data_vencimento 
        FROM orçamentos o 
        JOIN clientes c ON o.cliente_id = c.id 
        WHERE o.status = 'pendente' AND o.data_vencimento <= %s
    """, (hoje,))
    
    vencidos = cur.fetchall()
    cur.close()
    conn.close()
    
    return jsonify([{
        "id": v[0], 
        "cliente": v[1], 
        "vencimento": v[2],
        "alerta": "Orçamento expirando ou vencido!"
    } for v in vencidos])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)