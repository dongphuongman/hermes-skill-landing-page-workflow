# Mẫu feedback cho agent

Chất lượng feedback quyết định số vòng lặp. Feedback mơ hồ không chỉ khiến
agent sửa sai — nó còn khiến agent **sinh lại ảnh không cần thiết**, tốn tiền
thật.

## Cấu trúc bắt buộc

Mỗi lỗi là một khối độc lập gồm hai phần:

```
<Hiện trạng: mô tả cái đang sai, chỉ đích danh phần tử>
Yêu cầu sửa:
- <hành động cụ thể 1>
- <hành động cụ thể 2>
```

Nêu hiện trạng trước để agent định vị đúng phần tử; nêu yêu cầu sau để agent
biết đích đến. Thiếu vế đầu, agent đoán sai chỗ. Thiếu vế sau, agent tự quyết
theo cảm tính.

## Phân biệt quan trọng nhất: khối ảnh vs nội dung trong ảnh

Đây là chỗ gây lãng phí lớn nhất.

| Nói thế này | Agent hiểu | Hậu quả |
| --- | --- | --- |
| "ảnh bị lệch" | nội dung *bên trong* ảnh lệch | sinh lại toàn bộ ảnh mới — tốn tiền, không sửa đúng |
| "khối ảnh bị lệch lên trên so với cụm tiêu đề bên trái" | vị trí CSS của container | sửa đúng bằng CSS, không tốn lượt sinh ảnh |

Luôn nói rõ **"khối ảnh"/"container ảnh"** khi vấn đề là bố cục, và **"nội dung
trong ảnh"** khi thật sự cần sinh lại.

## Mẫu theo từng loại lỗi

### Ảnh hero sai kích thước / sai vị trí

```
Khối ảnh bên phải đang quá nhỏ và bị đẩy lệch lên trên so với cụm tiêu đề
bên trái. Giao diện mobile còn có một khoảng nền đen dưới ảnh đẩy nội dung
xuống dưới.
Yêu cầu sửa:
- Tăng kích thước khối ảnh lớn hơn đáng kể.
- Căn tâm khối ảnh ngang bằng với tâm cụm nội dung bên trái (tiêu đề + mô tả).
- Loại bỏ khoảng nền đen bên dưới ảnh để liền mạch với nền chung.
```

### Ảnh bị phóng to, chỉ thấy một góc

Triệu chứng đặc trưng của `object-cover` dùng nhầm chỗ. **Nêu thẳng tên thuộc
tính** — agent sẽ sửa trúng ngay thay vì đoán:

```
Các ảnh đang bị phóng to và chỉ hiển thị góc phần tư trên bên trái.
Nguyên nhân nghi ngờ: đang dùng object-cover thay vì object-contain.
Yêu cầu sửa:
- Đổi sang object-contain cho khối ảnh hero, các thẻ sản phẩm, và section
  The Architecture of Nature.
- KHÔNG sinh lại ảnh mới — nội dung bên trong ảnh đã đúng, chỉ sai cách hiển thị.
```

Dòng cuối là quan trọng nhất. Không có nó, agent rất dễ suy diễn thành "nội
dung ảnh lệch" rồi sinh lại cả loạt.

### Khối nội dung sai vị trí trái/phải

```
Phần 'Curated Assemblages' đang sai bố cục so với thiết kế gốc.
Yêu cầu sửa:
- Di chuyển khối tiêu đề và đoạn mô tả từ bên phải sang bên trái màn hình.
- Di chuyển dòng 'VIEW COMPLETE ARCHIVE' sang bên phải, ngang hàng với tiêu đề.
```

### Khoảng cách và bo góc

```
3 ảnh sản phẩm trong 'Curated Assemblages' đang xếp dính sát nhau và góc chưa
được bo.
Yêu cầu sửa:
- Tăng gap giữa 3 ảnh để bố cục thoáng hơn.
- Bo cong nhẹ các góc của 3 ảnh này.
```

### Khoảng cách dọc quá xa

```
Khoảng cách dọc giữa khối 'The Architecture of Nature' (bên trái) và danh sách
các bước quy trình (bên phải) đang quá xa. Mobile cũng tương tự nhưng xa theo
chiều dọc thay vì chiều ngang.
Yêu cầu sửa: Thu hẹp khoảng cách này để hai khối gắn kết hơn.
```

### Mobile

Đừng chỉ nói "sửa mobile". Nêu rõ lỗi nào lặp lại từ desktop, và lỗi nào là
riêng của mobile:

```
Hãy tối ưu lại giao diện Mobile. Áp dụng các lỗi khoảng cách và vị trí tương
tự bản Desktop đã nêu.
Riêng phần 'Curated Assemblages' trên mobile:
- Không xếp chồng 3 ảnh theo chiều dọc (làm trang bị kéo dài).
- Chuyển thành danh sách cuộn ngang (carousel).
- Bật auto-scroll mượt với hiệu ứng ease-in-out.
```

## Nguyên tắc gộp lỗi trong một lượt

**Nên gộp** các lỗi cùng loại hoặc cùng section — agent sửa một lần, ít rủi ro
mâu thuẫn.

**Không gộp** lỗi bố cục lớn với lỗi chi tiết nhỏ. Sửa bố cục làm dịch chuyển
mọi thứ bên dưới, nên các chỉnh chi tiết ở cùng lượt thường thành vô nghĩa hoặc
sai chỗ. Sửa bố cục trước, commit, rồi mới tinh chỉnh.

**Luôn commit giữa các lượt.** Lượt sau hỏng mà chưa commit là mất luôn phần
đã sửa đúng ở lượt trước:

```bash
python3 scripts/checkpoint commit "Feat: sua bo cuc hero va Curated Assemblages"
```

## Trước khi gửi feedback, tự hỏi

- Đã chỉ đích danh phần tử chưa, hay chỉ nói "phần trên cùng"?
- Có nhầm lẫn giữa *khối ảnh* và *nội dung trong ảnh* không?
- Có yêu cầu nào ngầm khiến agent phải sinh lại ảnh không? Có cần thật không?
- Đã xem cả desktop lẫn mobile chưa, hay chỉ mới xem một?
- Working tree đã commit trước khi giao lượt này chưa?
