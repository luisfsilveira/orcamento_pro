class Validators {
  static bool isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) return false;
    
    List<int> digits = cpf.split('').map(int.parse).toList();
    var calc = (int weight) => digits.getRange(0, weight).toList()
        .asMap().entries.map((e) => e.value * (weight + 1 - e.key)).reduce((a, b) => a + b) % 11;
    
    var check1 = calc(9) < 2 ? 0 : 11 - calc(9);
    var check2 = calc(10) < 2 ? 0 : 11 - calc(10);
    return digits[9] == check1 && digits[10] == check2;
  }

  static bool isValidCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpj.length != 14) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(cnpj)) return false;

    List<int> digits = cnpj.split('').map(int.parse).toList();
    var calc = (List<int> weights) => digits.getRange(0, weights.length).toList()
        .asMap().entries.map((e) => e.value * weights[e.key]).reduce((a, b) => a + b) % 11;

    var w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    
    var check1 = calc(w1) < 2 ? 0 : 11 - calc(w1);
    var check2 = calc(w2) < 2 ? 0 : 11 - calc(w2);
    return digits[12] == check1 && digits[13] == check2;
  }
}