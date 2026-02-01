import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/servico_model.dart';

class PdfService {
  static Future<File> gerarOrcamento({
    required String nomeCliente,
    required List<Servico> itens,
    required bool isSuperFuncao,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, // Correção do parâmetro
            children: [
              pw.Header(level: 0, child: pw.Text("Orcamento Profissional")),
              pw.Text("Cliente: $nomeCliente"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Qtde', 'Descricao', 'Total'],
                data: itens.map((item) {
                  return [
                    item.quantidade.toString(),
                    item.formatarParaExibicao(isSuperFuncao),
                    "R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}"
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/orcamento_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}