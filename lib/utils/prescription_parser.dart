import 'package:tech_care/models/appointment_model.dart';

// Class chứa kết quả trả về
class PrescriptionParseResult {
  final String diagnosis;
  final List<PrescriptionItem> medicines;

  PrescriptionParseResult({required this.diagnosis, required this.medicines});
}

class PrescriptionParser {
  
  static String normalizeText(String rawText) {
    String text = rawText;
    // Chuẩn hóa ký tự đầu dòng bị lỗi OCR (l/ -> 1., I. -> 1.)
    text = text.replaceAllMapped(RegExp(r'^([lLiIoO])[\.\/\s]', multiLine: true), (match) {
      String char = match.group(1)!.toLowerCase();
      if (char == 'l' || char == 'i') return '1.';
      return match.group(0)!;
    });
    return text;
  }

  static PrescriptionParseResult parse(String rawText) {
    final text = normalizeText(rawText);
    final lines = text.split('\n');

    List<PrescriptionItem> medicines = [];
    PrescriptionItem? currentItem;
    
    // Biến để lưu chẩn đoán
    String diagnosis = "";
    bool isCapturingDiagnosis = false;
    bool hasFoundFirstMedicine = false;

    // Regex dòng thuốc: 1/ hoặc 1. hoặc 1)
    final drugStartRegex = RegExp(r'^(\d+)[\.\)\/\s]+(.+)$');
    
    // Regex số lượng cuối dòng: "30,00 Viên" hoặc "30 Viên"
    final quantityAtEndRegex = RegExp(r'(\d+([.,]\d+)?)\s*([a-zA-ZăâêôơưđĂÂÊÔƠƯĐ]+)?$');

    final usageKeywords = ['sáng', 'trưa', 'chiều', 'tối', 'uống', 'ăn', 'bôi', 'nhỏ', 'lần', 'viên', 'ngày'];

    for (String rawLine in lines) {
      String line = rawLine.trim();
      if (line.isEmpty) continue;
      
      // Chuyển về chữ thường để so sánh từ khóa
      String lowerLine = line.toLowerCase();

      // --- 1. BẮT ĐẦU TÌM CHẨN ĐOÁN ---
      if (lowerLine.startsWith("chẩn đoán") || lowerLine.startsWith("chan doan")) {
        isCapturingDiagnosis = true;
        // Lấy nội dung sau dấu hai chấm (nếu có)
        int colonIndex = line.indexOf(':');
        if (colonIndex != -1) {
          diagnosis += line.substring(colonIndex + 1).trim();
        } else {
          // Nếu không có dấu :, lấy từ chữ thứ 2 trở đi
          diagnosis += line.replaceFirst(RegExp(r'chẩn đoán', caseSensitive: false), '').trim();
        }
        continue;
      }

      // --- 2. NHẬN DIỆN THUỐC ---
      final drugMatch = drugStartRegex.firstMatch(line);
      
      if (drugMatch != null) {
        // Khi gặp thuốc đầu tiên -> Dừng lấy chẩn đoán
        hasFoundFirstMedicine = true;
        isCapturingDiagnosis = false;

        if (currentItem != null) medicines.add(currentItem);

        String content = drugMatch.group(2) ?? ""; 
        String name = content;
        String dosage = "";

        // Tìm số lượng ở cuối dòng
        final endQtyMatch = quantityAtEndRegex.firstMatch(content);
        if (endQtyMatch != null) {
           dosage = endQtyMatch.group(0)?.trim() ?? "";
           name = content.substring(0, endQtyMatch.start).trim();
        }

        // Xóa ký tự thừa
        name = name.replaceAll(RegExp(r'[-–:\.]$'), '').trim();

        currentItem = PrescriptionItem(
          name: name,
          dosage: dosage, 
          frequency: '', 
          duration: '',
        );
      } 
      // --- 3. XỬ LÝ CÁC DÒNG KHÁC ---
      else {
        // Nếu chưa gặp thuốc mà đang bật cờ lấy chẩn đoán -> Cộng dồn vào chẩn đoán
        if (!hasFoundFirstMedicine && isCapturingDiagnosis) {
          // Kiểm tra xem dòng này có phải là rác không (Mã BN, Bệnh nhân...)
          if (!_isHeaderNoise(line)) {
            diagnosis += " $line";
          }
        }
        // Nếu đã gặp thuốc -> Đây là HDSD
        else if (hasFoundFirstMedicine && currentItem != null) {
          // Logic HDSD
          if (_isUsageLine(line, usageKeywords)) {
            String newFreq = currentItem.frequency;
            if (newFreq.isNotEmpty) newFreq += "\n"; 
            newFreq += line;

            currentItem = PrescriptionItem(
              name: currentItem.name,
              dosage: currentItem.dosage,
              frequency: newFreq,
              duration: currentItem.duration,
            );
          }
        }
      }
    }

    if (currentItem != null) medicines.add(currentItem);

    // Làm sạch chuỗi chẩn đoán lần cuối
    diagnosis = diagnosis.replaceAll(RegExp(r'\s+'), ' ').trim();

    return PrescriptionParseResult(
      diagnosis: diagnosis,
      medicines: medicines
    );
  }

  // Hàm kiểm tra dòng HDSD
  static bool _isUsageLine(String line, List<String> keywords) {
    String lower = line.toLowerCase();
    if (keywords.any((kw) => lower.contains(kw))) return true;
    if (line.startsWith('+') || line.startsWith('-')) return true;
    return false;
  }

  // Hàm lọc rác phần Header (tránh cộng nhầm vào Chẩn đoán)
  static bool _isHeaderNoise(String line) {
    final lower = line.toLowerCase();
    if (lower.contains("mã bn") || lower.contains("đối tượng")) return true;
    if (lower.contains("bệnh nhân") || lower.contains("địa chỉ")) return true;
    if (lower.contains("giới tính") || lower.contains("năm sinh")) return true;
    if (lower.contains("bhyt")) return true;
    return false;
  }
}