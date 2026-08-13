---
name: landing-page-workflow
description: >-
  Quy trình dựng landing page từ ảnh thiết kế bằng Hermes Agent — preflight
  công cụ, scaffold Vite React TypeScript, mốc Git an toàn, checkpoint từng
  bước, feedback có cấu trúc, build và rollback. Dùng khi người dùng nói:
  làm landing page, dựng trang đích, tạo trang web từ ảnh thiết kế, clone
  giao diện này, code trang này từ Figma/screenshot, build landing page,
  chuyển ảnh thành web, sửa layout trang landing. Also triggers in English:
  build a landing page, turn this design into code, image to landing page,
  clone this UI, scaffold a Vite React landing page. Điều phối các skill
  image-to-code, design-taste-frontend, imagegen-frontend-web,
  imagegen-frontend-mobile — không thay thế chúng.
version: 1.0.0
license: MIT
platforms: [macos, linux]
metadata:
  hermes:
    tags: [landing-page, frontend, vite, react, typescript, image-to-code, design, git, workflow]
    related_skills: [image-to-code, design-taste-frontend, imagegen-frontend-web, imagegen-frontend-mobile]
---

# Quy trình dựng Landing Page bằng Hermes Agent

Skill này **không** dạy thẩm mỹ thiết kế. Phần đó đã có `image-to-code`,
`design-taste-frontend` và bộ `imagegen-frontend-*` lo. Skill này lo phần
*quy trình*: đảm bảo công cụ đã sẵn sàng trước khi bắt đầu, dự án có mốc
Git để quay lui, agent dừng lại ở đúng các điểm kiểm tra, và feedback được
viết đủ cụ thể để sửa trúng.

Lý do tồn tại: thất bại thường gặp khi dựng landing page bằng agent **không
phải** là code xấu. Đó là agent chạy một mạch 20 phút, sinh ra thứ lệch bố
cục, rồi không có cách nào quay lại trạng thái tốt trước đó. Hoặc `image_gen`
chưa bật nên mọi ảnh thành placeholder vỡ, phát hiện ra sau khi đã viết xong
toàn bộ component.

## Nguyên tắc bất di bất dịch

1. **Không giao việc khi working tree bẩn.** Trước mỗi lượt giao việc lớn cho
   agent, `git status` phải sạch. Không có mốc sạch thì không có đường lui.
2. **Preflight trước, code sau.** `image_gen` chưa bật hoặc thiếu skill thì
   dừng lại báo người dùng, đừng bắt đầu rồi hỏng giữa chừng.
3. **Checkpoint sau mỗi giai đoạn**, không chạy một mạch từ đầu đến cuối.
   Người dùng xác nhận đầu ra rồi mới sang bước kế.
4. **Feedback phải chỉ đích danh phần tử và hành vi mong muốn**, không nói
   "trông chưa đẹp". Xem `references/feedback-prompts.md`.
5. **Luôn `git stash push -u` trước khi `git reset --hard`.** Reset xóa vĩnh
   viễn thay đổi chưa commit và không đụng tới file untracked; thiếu stash là
   mất trắng.

## Khi nào dùng skill này

**Dùng:**
- Người dùng đưa ảnh thiết kế (screenshot, Figma export, ảnh mẫu) và muốn dựng
  thành trang web.
- Người dùng nói "làm landing page", "dựng trang đích", "clone giao diện này".
- Đang tinh chỉnh một landing page đã dựng và cần vòng feedback có kỷ luật.
- Cần khôi phục sau khi agent làm hỏng mã nguồn.

**Không dùng:**
- Sửa nội dung chữ hoặc đổi màu lặt vặt trên trang đã hoàn thiện — chỉnh trực
  tiếp, đừng chạy cả quy trình.
- Ứng dụng web có state phức tạp, routing, backend. Skill này tối ưu cho trang
  đích một luồng.
- Dự án đã có sẵn hệ thống build khác (Next.js, Astro, Nuxt) — giữ nguyên hệ
  thống đó, chỉ mượn phần checkpoint và feedback.

## Giai đoạn 0 — Preflight (bắt buộc)

```bash
python3 scripts/preflight
```

Kiểm tra: `node`/`npm`/`git` có mặt, Hermes CLI chạy được, công cụ `image_gen`
đã bật, khối `image_gen` có trong `config.yaml`, và 4 skill thiết kế đã cài.

Exit 0 = sẵn sàng, 1 = thiếu thứ gì đó, 2 = lỗi nội bộ.

Nếu `image_gen` chưa bật:

```bash
hermes tools list | grep image_gen
hermes tools enable image_gen
```

Nếu chưa cấu hình provider, thêm khối `image_gen` vào `$HERMES_HOME/config.yaml`.
Chọn **một** provider — đổi `provider` + `model` theo bảng bên dưới:

```yaml
image_gen:
  provider: openrouter               # openrouter | openai | google | xai
  use_gateway: false                 # chỉ cần cho openrouter; bỏ với provider khác
  model: google/gemini-3-pro-image
```

| provider | model ví dụ | key đặt qua `hermes config set` |
| --- | --- | --- |
| `openrouter` | `google/gemini-3-pro-image`, `openai/gpt-5-image`, `google/gemini-2.5-flash-image` | `OPENROUTER_API_KEY` |
| `openai` | `gpt-image-1` | `OPENAI_API_KEY` |
| `google` | `gemini-2.5-flash-image` | `GEMINI_API_KEY` |
| `xai` | `grok-2-image` | `XAI_API_KEY` |

```bash
hermes config set OPENROUTER_API_KEY sk-or-v1-...   # đổi tên key theo provider đã chọn
```

> **Grok image không có trên OpenRouter** — muốn dùng Grok phải đi provider `xai`
> trực tiếp. Gemini và GPT image thì có sẵn trên OpenRouter, chỉ cần đổi `model`.
> OpenRouter tiện nhất vì một key phủ được cả Gemini lẫn GPT image.

> **Cảnh báo chi phí.** Khác với LLM, hầu hết mô hình sinh ảnh **không có gói
> miễn phí** và tính tiền theo từng lượt. Một trang landing với ảnh riêng cho
> mỗi section có thể là hàng chục lượt sinh ảnh. Đặt budget trên tài khoản
> provider trước khi chạy, và theo dõi chi phí sau mỗi lượt.

Cài 4 skill thiết kế nếu thiếu:

```bash
hermes skills install Leonxlnx/taste-skill/skills/image-to-code-skill --name image-to-code
hermes skills install Leonxlnx/taste-skill/skills/taste-skill --name taste
hermes skills install Leonxlnx/taste-skill/skills/imagegen-frontend-web --name imagegen-frontend-web
hermes skills install Leonxlnx/taste-skill/skills/imagegen-frontend-mobile --name imagegen-frontend-mobile
```

> Lưu ý: skill thứ hai cài với `--name taste` nhưng Hermes ưu tiên thuộc tính
> `name` trong `SKILL.md` của tác giả, nên nó hiển thị là
> **`design-taste-frontend`**. Khi viết prompt phải gọi đúng tên hiển thị này,
> gọi `taste` sẽ không khớp.

## Giai đoạn 1 — Scaffold + mốc an toàn

```bash
npm create vite@latest <ten-du-an>
```

Lựa chọn: **React** (bộ taste-skill tối ưu cho kiến trúc component TSX),
**TypeScript** (bắt lỗi kiểu ngay lúc viết, cả người lẫn agent),
**oxlint** (nhanh hơn ESLint nhiều lần, không làm chậm vòng lặp).

Rồi tạo mốc Git — đây là bước người ta hay bỏ qua và luôn hối hận:

```bash
cd <ten-du-an>
git init
cat << 'EOF' > .gitignore
node_modules/
dist/
.env
.env.local
*.log
.DS_Store
EOF
git add .
git commit -m "Chore: Khoi tao du an Vite React TypeScript ban dau"
```

Không cần remote. Mục đích duy nhất là có chỗ quay về trong 1 giây.

Sau đó kết nối thư mục vào Hermes: Desktop thì **Create Project → Add Folder**;
CLI thì `cd <ten-du-an> && hermes` là agent tự nhận thư mục hiện tại.

## Giai đoạn 2 — Giao việc

Kiểm tra tree sạch trước:

```bash
python3 scripts/checkpoint guard
```

Đính kèm ảnh thiết kế vào khung chat (hoặc để ảnh trong thư mục dự án rồi nêu
tên file). Prompt gọi đích danh các skill:

```
Sử dụng skill image-to-code và design-taste-frontend để tạo landing page dựa
trên hình ảnh được cung cấp, sử dụng skill imagegen-frontend-web và
imagegen-frontend-mobile để sinh ảnh cho trang web.
```

Prompt ngắn là đủ — chi tiết thiết kế nằm trong ảnh, và 4 skill kia biết cách
đọc. Đừng mô tả lại bằng lời những gì ảnh đã thể hiện.

## Giai đoạn 3 — Checkpoint và feedback

Chạy dev server, xem trên **cả desktop lẫn mobile** trước khi feedback:

```bash
npm run dev
```

Vite mặc định cổng 5173; nếu bị chiếm nó tự nhảy sang 5174, 5175, 5176... Đọc
đúng cổng trong output, đừng giả định.

Rà theo thứ tự này — đi từ lỗi cấu trúc xuống chi tiết, vì sửa bố cục thường
làm thay đổi mọi thứ bên dưới:

1. Bố cục section có đúng thứ tự và vị trí trái/phải như ảnh mẫu không
2. Kích thước và căn chỉnh của khối ảnh chính (hero)
3. Khoảng cách dọc/ngang giữa các khối
4. Chi tiết: bo góc, gap trong grid, typography
5. Mobile: có bị bê nguyên layout desktop không, list dài có nên chuyển carousel không

Viết feedback theo mẫu trong `references/feedback-prompts.md`. Nguyên tắc:
**mỗi lỗi một khối, nêu hiện trạng rồi mới nêu yêu cầu sửa.**

Commit ngay khi một lượt sửa cho kết quả tốt:

```bash
python3 scripts/checkpoint commit "Feat: sua bo cuc hero va Curated Assemblages"
```

Chưa commit mà giao lượt tiếp theo là tự bỏ mất trạng thái tốt vừa đạt được.

## Giai đoạn 4 — Build và kiểm tra

```bash
python3 scripts/verify-build
```

Script chạy `npm run build` rồi quét `dist/` tìm tham chiếu ảnh trỏ tới file
không tồn tại — lỗi ảnh 404 là lỗi phổ biến nhất và không hiện ra ở dev server
vì Vite phục vụ file khác đường dẫn.

Xem trước bản build bằng `npm run preview` (cổng 4173). **Không** mở trực tiếp
`dist/index.html` bằng trình duyệt — giao thức `file://` chặn ES module, trang
sẽ trắng và báo lỗi CORS gây hiểu nhầm là build hỏng.

## Giai đoạn 5 — Rollback khi hỏng

Thang từ nhẹ tới nặng, đi tuần tự, đừng nhảy thẳng xuống cuối:

```bash
python3 scripts/checkpoint status          # 1. agent đã đổi những gì
python3 scripts/checkpoint save "truoc-khi-rollback"   # 2. stash -u, luôn làm trước
git restore <duong-dan-file>               # 3. khôi phục đúng 1 file
python3 scripts/checkpoint rollback        # 4. về HEAD (tự stash trước)
```

`checkpoint rollback` luôn `git stash push -u` trước khi `git reset --hard`, nên
kể cả reset nhầm vẫn lấy lại được bằng `git stash pop`.

## Bẫy thường gặp

1. **Gọi sai tên skill.** `taste` không tồn tại trong danh sách; tên thật là
   `design-taste-frontend`. Kiểm tra bằng `hermes skills list`.
2. **Quên bật `image_gen`.** Agent vẫn dựng xong trang nhưng toàn placeholder.
   Preflight bắt được, nhưng phải chạy *trước*.
3. **Chi phí sinh ảnh vượt dự tính.** Một ảnh ngang riêng cho mỗi section, nhân
   với desktop + mobile, nhân với số lượt sinh lại sau feedback.
4. **`object-cover` thay vì `object-contain`.** Triệu chứng: ảnh bị phóng to và
   chỉ thấy một góc. Đây là lỗi CSS lặp đi lặp lại; nêu thẳng tên thuộc tính
   trong feedback thay vì mô tả hiện tượng, agent sẽ sửa trúng ngay.
5. **Feedback mơ hồ sinh ra công việc thừa.** Nói "ảnh bị lệch" có thể khiến
   agent tưởng *nội dung bên trong ảnh* lệch và sinh lại toàn bộ ảnh mới — tốn
   tiền, không sửa đúng vấn đề. Phải nói rõ là *khối ảnh* lệch hay *nội dung
   trong ảnh* lệch.
6. **Trình duyệt cache bản cũ.** Agent báo sửa xong mà giao diện không đổi:
   hard reload (giữ nút reload → chọn Empty Cache and Hard Reload).
7. **Mở `dist/index.html` bằng `file://`.** Trang trắng, lỗi CORS, tưởng build
   hỏng. Dùng `npm run preview`.
8. **`git reset --hard` không đụng file untracked.** File mới agent tạo vẫn còn
   nguyên sau reset. Muốn dọn sạch phải thêm `git clean -fd` — cực kỳ cẩn trọng.
9. **Sửa nhiều lỗi trong một lượt mà không commit giữa chừng.** Lượt sau hỏng
   là mất luôn phần đã sửa đúng ở lượt trước.

## Checklist xác minh

- [ ] `python3 scripts/preflight` exit 0 trước khi bắt đầu
- [ ] Có commit mốc ban đầu trước lượt giao việc đầu tiên
- [ ] `git status` sạch trước mỗi lượt giao việc lớn
- [ ] Đã xem trên cả desktop và mobile trước khi feedback
- [ ] Mỗi lượt sửa đạt kết quả tốt đều được commit ngay
- [ ] `python3 scripts/verify-build` exit 0, không có ảnh 404
- [ ] Đã xem bản build qua `npm run preview`, không phải `file://`

## Tệp trong skill

- `scripts/preflight` — kiểm tra công cụ, tool, skill trước khi bắt đầu
- `scripts/checkpoint` — guard / save / commit / rollback / status trên Git
- `scripts/verify-build` — build và dò tham chiếu ảnh hỏng trong `dist/`
- `scripts/selftest` — kiểm thử các script trên fixture
- `references/feedback-prompts.md` — mẫu feedback theo từng loại lỗi bố cục
- `references/troubleshooting.md` — lỗi thường gặp và cách xử lý

Mọi script là Python 3 stdlib thuần (không thêm dependency nào vào máy bạn) và
gọi được bằng `python3 scripts/<tên>` kể cả khi mất cờ execute sau khi cài.
