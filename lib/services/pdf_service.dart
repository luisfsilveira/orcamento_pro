import 'dart:io';
import 'package:pdf/pdf.dart';
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
            cross: pw.CrossAxisAlignment.start,
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
              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Total Geral: R\$ ${itens.fold(0.0, (sum, item) => sum + (item.preco * item.quantidade)).toStringAsFixed(2)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Salva o arquivo no diretório temporário do dispositivo
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/orcamento_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}