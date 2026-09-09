import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'order_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String serviceName;
  final double servicePrice;
  final String providerName;

  const PaymentScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.providerName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0 = Pix, 1 = Cartão
  bool _isProcessing = false;

  final String _pixCopyPasteKey = "00020126580014BR.GOV.BCB.PIX0136redglow-pay-pix-key-demo5204000053039865802BR5920REDGLOW TECNOLOGIA6009CURITIBA62070503***6304E2D1";

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simula o tempo de validação do pagamento no gateway/Firebase
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Redireciona para a tela de confirmação do pedido
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderConfirmationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE8408C);
    const backgroundColor = Color(0xFF0B0811);
    const cardColor = Color(0xFF181324);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Pagamento do Agendamento',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo do Serviço
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo do Atendimento',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.serviceName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'R\$ ${widget.servicePrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profissional: ${widget.providerName}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Forma de Pagamento',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Seleção de Método (Pix / Cartão)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _selectedMethod == 0 ? primaryColor.withOpacity(0.2) : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == 0 ? primaryColor : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, color: _selectedMethod == 0 ? primaryColor : Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            'Pix Instantâneo',
                            style: TextStyle(
                              color: _selectedMethod == 0 ? primaryColor : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _selectedMethod == 1 ? primaryColor.withOpacity(0.2) : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == 1 ? primaryColor : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, color: _selectedMethod == 1 ? primaryColor : Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            'Cartão',
                            style: TextStyle(
                              color: _selectedMethod == 1 ? primaryColor : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detalhes do Pix ou Cartão
            if (_selectedMethod == 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code, size: 140, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Escaneie o QR Code ou copie a chave abaixo:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _pixCopyPasteKey));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chave Pix copiada para a área de transferência!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar Código Pix'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Número do Cartão',
                        labelStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.credit_card, color: Colors.white54),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Validade (MM/AA)',
                              labelStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              labelStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Botão de Confirmação
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar e Finalizar Agendamento',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}