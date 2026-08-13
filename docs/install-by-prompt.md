# Cài bằng cách dán prompt cho Hermes tự làm

Thay vì chạy `install.sh` thủ công, bạn có thể dán prompt bên dưới vào một
session Hermes và để agent tự cài skill này cùng 4 skill thiết kế đi kèm.

## Đọc trước — hai việc KHÔNG giao cho agent

**1. Đừng để agent chạy lệnh đặt API key.**

```bash
# TỰ CHẠY TRONG TERMINAL — đừng dán vào chat Hermes
hermes config set OPENROUTER_API_KEY sk-or-v1-xxxxxxxx
```

Nếu bạn gõ key vào khung chat, nó nằm lại trong transcript, tức là nằm trong
`state.db`. Ở đó nó bị FTS index, hiện ra trong `session_search`, và hiện cả
trong snippet của dashboard Session Analyzer. Xoá tin nhắn ở giao diện cũng
không chắc dọn được bản ghi đã index. Key rò rỉ theo đường này là rò rỉ vĩnh
viễn cho tới khi bạn revoke nó.

Prompt bên dưới được viết để agent **kiểm tra** key đã có chưa mà không bao giờ
in ra hay yêu cầu bạn cung cấp.

**2. Đừng nhờ agent "test thử sinh một tấm ảnh".**

Mỗi lượt sinh ảnh đều tính tiền, và hầu hết mô hình image generation không có
gói miễn phí. Kiểm tra cấu hình đúng chưa thì đọc config là đủ; đừng đốt tiền
để xác nhận một thứ có thể xác nhận bằng cách đọc file.

Ngoài ra: nếu `terminal.backend` của bạn đặt là `docker`, tool terminal chạy
trong sandbox riêng và không thấy `HERMES_HOME` thật — lúc đó dùng `install.sh`
trực tiếp.

---

## Prompt cài đặt

Mở session Hermes mới, dán nguyên khối:

```text
Cài skill landing-page-workflow và các skill thiết kế đi kèm cho máy này.
Làm tuần tự, dừng lại và báo tôi nếu bất kỳ bước nào không như mong đợi.

1. Xác định HERMES_HOME: dùng biến môi trường nếu có; không thì kiểm tra
   /opt/data (bản Docker) rồi tới ~/.hermes. In ra đường dẫn đã chọn và xác
   nhận thư mục tồn tại.

2. Cài skill quy trình:
   hermes skills install dongphuongman/hermes-skill-landing-page-workflow/landing-page-workflow --name landing-page-workflow -y
   Nếu lệnh này thất bại, clone repo rồi chạy installer:
     git clone --depth 1 https://github.com/dongphuongman/hermes-skill-landing-page-workflow.git /tmp/lpw
     cd /tmp/lpw && chmod +x install.sh && HERMES_HOME=<đường dẫn bước 1> ./install.sh
   Nếu không ra được mạng, DỪNG LẠI và báo tôi — đừng tự tạo file thay thế.

3. Cài 4 skill thiết kế (bỏ qua cái nào đã có):
   hermes skills install Leonxlnx/taste-skill/skills/image-to-code-skill --name image-to-code
   hermes skills install Leonxlnx/taste-skill/skills/taste-skill --name taste
   hermes skills install Leonxlnx/taste-skill/skills/imagegen-frontend-web --name imagegen-frontend-web
   hermes skills install Leonxlnx/taste-skill/skills/imagegen-frontend-mobile --name imagegen-frontend-mobile

4. Chạy: hermes skills list
   Xác nhận có đủ 5 skill. Lưu ý skill thứ hai hiển thị tên là
   "design-taste-frontend" chứ không phải "taste" — đó là bình thường, Hermes
   ưu tiên thuộc tính name trong SKILL.md của tác giả. Báo cho tôi tên hiển thị
   THẬT của từng skill, vì prompt sau này phải gọi đúng tên đó.

5. Kiểm tra công cụ image_gen:
   hermes tools list | grep image_gen
   Nếu chưa bật: hermes tools enable image_gen

6. Đọc $HERMES_HOME/config.yaml và cho tôi biết khối image_gen đã có
   provider và model chưa.
   QUAN TRỌNG: KHÔNG in ra, KHÔNG trích dẫn, KHÔNG ghi lại bất kỳ giá trị API
   key nào bạn nhìn thấy ở bất cứ đâu. Chỉ trả lời có/không về việc key đã được
   cấu hình. Nếu thiếu key, chỉ cần nói thiếu — tôi sẽ tự đặt trong terminal.

7. Chạy selftest của skill:
   python3 $HERMES_HOME/skills/landing-page-workflow/scripts/selftest
   Kỳ vọng 19 passed, 0 failed.

8. Chạy preflight:
   python3 $HERMES_HOME/skills/landing-page-workflow/scripts/preflight
   Báo lại nguyên văn output.

9. Dọn /tmp/lpw nếu có.

KHÔNG làm những việc sau: đừng chạy lệnh nào đặt hay sửa API key; đừng gọi tool
image_gen để "test thử" (mỗi lượt sinh ảnh đều tốn tiền); đừng tạo dự án mẫu.

Cuối cùng tóm tắt: đã cài skill nào, tên hiển thị thật của từng cái, và còn
thiếu gì để tôi bắt đầu dựng landing page.
```

---

## Sau khi cài

Skill được nạp vào ngữ cảnh lúc session khởi tạo, nên **mở session mới** rồi
mới dùng. Session hiện tại chưa thấy skill vừa cài.

Nếu preflight báo thiếu API key, tự chạy trong terminal:

```bash
hermes config set OPENROUTER_API_KEY sk-or-v1-xxxxxxxx
```

Và thêm khối `image_gen` vào `$HERMES_HOME/config.yaml` — chọn **một** provider,
đổi `provider` + `model` theo bảng:

```yaml
image_gen:
  provider: openrouter               # openrouter | openai | google | xai
  use_gateway: false                 # chỉ cần cho openrouter; bỏ với provider khác
  model: google/gemini-3-pro-image
```

| provider | model ví dụ | key |
| --- | --- | --- |
| `openrouter` | `google/gemini-3-pro-image`, `openai/gpt-5-image` | `OPENROUTER_API_KEY` |
| `openai` | `gpt-image-1` | `OPENAI_API_KEY` |
| `google` | `gemini-2.5-flash-image` | `GEMINI_API_KEY` |
| `xai` | `grok-2-image` | `XAI_API_KEY` |

> Grok image không có trên OpenRouter — muốn dùng Grok phải đi provider `xai`
> trực tiếp.

---

## Prompt kiểm tra

```text
Kiểm tra bộ skill dựng landing page đã sẵn sàng chưa:

1. hermes skills list — xác nhận có landing-page-workflow, image-to-code,
   design-taste-frontend, imagegen-frontend-web, imagegen-frontend-mobile.
2. python3 $HERMES_HOME/skills/landing-page-workflow/scripts/preflight
3. Đọc SKILL.md của landing-page-workflow và tóm tắt cho tôi 5 nguyên tắc bất
   di bất dịch trong đó.

Bước 3 là để xác nhận skill thực sự đọc được, không chỉ tồn tại trên đĩa.
Đừng gọi image_gen để test.
```

Bước 3 quan trọng hơn vẻ ngoài: một file `SKILL.md` sai frontmatter vẫn nằm
trên đĩa và vẫn hiện trong `skills list`, nhưng agent không dùng được. Bắt agent
tóm tắt nội dung là cách rẻ nhất để biết nó có thực sự đọc được hay không.

---

## Prompt bắt đầu dự án

Sau khi cài xong, đây là prompt khởi động một landing page mới:

```text
Dùng skill landing-page-workflow để dựng một landing page mới.

Bắt đầu từ Giai đoạn 0: chạy preflight và báo kết quả. Nếu preflight không
exit 0, DỪNG LẠI và báo tôi cần sửa gì — đừng scaffold khi công cụ chưa sẵn sàng.

Nếu preflight sạch, sang Giai đoạn 1: scaffold dự án Vite React TypeScript tên
<tên-dự-án>, tạo .gitignore và commit mốc an toàn ban đầu. Rồi DỪNG LẠI để tôi
đính ảnh thiết kế trước khi bạn viết bất kỳ component nào.
```

Chữ "DỪNG LẠI" ở cuối là cố ý. Toàn bộ giá trị của skill nằm ở chỗ agent không
chạy một mạch từ scaffold tới trang hoàn chỉnh rồi bạn mới phát hiện lệch bố cục.

---

## Prompt cập nhật

```text
Cập nhật skill landing-page-workflow lên bản mới nhất: clone lại repo
dongphuongman/hermes-skill-landing-page-workflow vào thư mục tạm, chạy ./install.sh
với HERMES_HOME đúng của máy này, chạy selftest xác nhận 19 passed, rồi dọn
thư mục tạm. Đừng đụng tới 4 skill thiết kế và đừng sửa config.yaml.
```

---

## Prompt gỡ cài đặt

```text
Gỡ skill landing-page-workflow:
1. Xóa thư mục $HERMES_HOME/skills/landing-page-workflow.
2. Xác nhận bằng: hermes skills list | grep landing-page
3. GIỮ NGUYÊN 4 skill thiết kế (image-to-code, design-taste-frontend,
   imagegen-frontend-web, imagegen-frontend-mobile) — chúng độc lập và vẫn dùng
   được. Đừng đụng tới config.yaml hay cấu hình image_gen.
```

---

## Vì sao prompt viết chặt như vậy

**"KHÔNG in ra bất kỳ API key nào"** — không có dòng này, một agent đang đọc
`config.yaml` để kiểm tra cấu hình rất tự nhiên sẽ trích cả khối ra cho bạn xem,
kéo theo key vào transcript.

**"đừng gọi image_gen để test thử"** — agent hay chủ động xác minh. Ở đây mỗi
lần xác minh là một lần tính tiền, và chẳng chứng minh thêm được gì so với đọc
config.

**"báo cho tôi tên hiển thị THẬT"** — `--name taste` không quyết định tên hiển
thị. Gọi sai tên trong prompt thì skill không kích hoạt, và triệu chứng rất khó
đoán: agent vẫn trả lời, chỉ là không có tư duy thiết kế nào được áp dụng.

**"đừng tự tạo file thay thế"** — gặp lỗi mạng, agent dễ tự viết ra một
`SKILL.md` "tương đương" theo mô tả. Bạn sẽ có skill chạy được nhưng không phải
skill này, và sẽ không nhận ra cho tới lúc quy trình cư xử khác dự kiến.
