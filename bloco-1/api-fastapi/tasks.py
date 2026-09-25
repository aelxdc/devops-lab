# tasks.py
import logging
import time

logger = logging.getLogger("worker")

def process_order_task(order_id: int, customer_id: int):
    """Simula o processamento em background (ex: envio de e-mail, integração de pagamento)"""
    logger.info(f"[JOB INICIADO] Processando pedido #{order_id} para cliente #{customer_id}...")
    time.sleep(3)  # Simula tempo de processamento assíncrono
    logger.info(f"[JOB CONCLUÍDO] Pedido #{order_id} processado com sucesso!")