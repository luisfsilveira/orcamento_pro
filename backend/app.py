from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# Pega a URI de conexão diretamente do Docker (Estratégia Anti-Conflito)
DB_URI = os.getenv('DB_URI', 'postgresql://admin_orcamento:senha_orcamento_2026@db_orcamento:5432/db_orcamento_pro')

def get_db_connection():
    return psycopg2.connect(DB_URI)

@app.route('/status', methods=['GET'])
def status():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({"status": "Conectado ao PostgreSQL com sucesso"}), 200
    except Exception as e:
        return jsonify({"status": "Erro", "detalhe": str(e)}), 500

@app.route('/alertas/vencimento', methods=['GET'])
def verificar_vencimentos():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        hoje = datetime.now().strftime('%Y-%m-%d')
        
        # Sua lógica original mantida e protegida
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
    except Exception as e:
        return jsonify({"erro": str(e)}), 500

if __name__ == '__main__':
    # Porta interna 5000 (O Traefik cuida do resto)
    app.run(host='0.0.0.0', port=5000)