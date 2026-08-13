# hermes-skill-landing-page-workflow

Skill điều phối quy trình dựng landing page từ ảnh thiết kế bằng Hermes Agent —
preflight công cụ, mốc Git an toàn, checkpoint từng bước, feedback có cấu trúc,
build và rollback.

**Skill này không dạy thẩm mỹ thiết kế.** Phần đó đã có bộ
[`Leonxlnx/taste-skill`](https://github.com/Leonxlnx/taste-skill) lo:
`image-to-code`, `design-taste-frontend`, `imagegen-frontend-web`,
`imagegen-frontend-mobile`. Skill này lo phần *quy trình* quanh chúng.

Lý do: thất bại khi dựng landing page bằng agent thường không phải code xấu.
Đó là agent chạy một mạch 20 phút, sinh ra thứ lệch bố cục, rồi không có đường
quay lại. Hoặc `image_gen` chưa bật nên mọi ảnh thành placeholder — phát hiện
sau khi đã viết xong toàn bộ component.

## Có gì

| Thành phần | Vai trò |
| --- | --- |
| `SKILL.md` | Quy trình 6 giai đoạn, 5 nguyên tắc bất di bất dịch, 9 bẫy thường gặp |
| `scripts/preflight` | Kiểm tra node/npm/git, `image_gen` đã bật, khối config, 4 skill đã cài |
| `scripts/checkpoint` | `guard` / `status` / `save` / `commit` / `rollback` / `restore` trên Git |
| `scripts/verify-build` | Build rồi dò tham chiếu ảnh hỏng trong `dist/` |
| `scripts/selftest` | 18 test trên fixture, không cần mạng |
| `references/feedback-prompts.md` | Mẫu feedback theo từng loại lỗi bố cục |
| `references/troubleshooting.md` | Lỗi thường gặp và cách xử lý |

## Cài

```bash
git clone https://github.com/manphuongdong/hermes-skill-landing-page-workflow.git
cd hermes-skill-landing-page-workflow
chmod +x install.sh
./install.sh                        # hoặc HERMES_HOME=/opt/data ./install.sh
```

Kiểm tra: `hermes skills list | grep landing-page-workflow`

Không muốn động vào shell? **[docs/install-by-prompt.md](docs/install-by-prompt.md)**
có sẵn prompt để dán vào Hermes cho agent tự cài, kiểm tra, cập nhật và gỡ.
Đọc phần cảnh báo đầu file trước: **đừng để agent chạy lệnh đặt API key** — key
sẽ nằm lại trong `state.db` và bị FTS index.

Cài luôn 4 skill thiết kế nếu chưa có:

```bash
hermes skills install Leonxlnx/taste-skill/skills/image-to-code-skill --name image-to-code
hermes skills install Leonxlnx/taste-skill/skills/taste-skill --name taste
hermes skills install Leonxlnx/taste-skill/skills/imagegen-frontend-web --name imagegen-frontend-web
hermes skills install Leonxlnx/taste-skill/skills/imagegen-frontend-mobile --name imagegen-frontend-mobile
```

> Skill thứ hai cài với `--name taste` nhưng hiển thị là **`design-taste-frontend`** —
> Hermes ưu tiên thuộc tính `name` trong `SKILL.md` của tác giả. Prompt phải gọi
> đúng tên hiển thị.

## Dùng

```bash
# Đường dẫn tới script sau khi cài (đổi HERMES_HOME nếu dùng bản Docker):
SKILL="${HERMES_HOME:-$HOME/.hermes}/skills/landing-page-workflow"

python3 "$SKILL/scripts/preflight"                  # 0. trước khi bắt đầu
npm create vite@latest my-landing                   # 1. React + TypeScript + oxlint
cd my-landing && git init && git add . && git commit -m "Chore: khoi tao"
python3 "$SKILL/scripts/checkpoint" guard           # 2. tree sạch mới giao việc
# → đính ảnh thiết kế vào chat, gọi 4 skill trong prompt
npm run dev                                         # 3. xem cả desktop lẫn mobile
# → feedback theo references/feedback-prompts.md
python3 "$SKILL/scripts/checkpoint" commit "Feat: ..."   #    commit ngay khi đạt
python3 "$SKILL/scripts/verify-build"               # 4. build + dò ảnh 404
```

## Yêu cầu

- Python 3.9+ (stdlib thuần — không thêm dependency nào vào máy bạn)
- Node.js 18+, npm, git
- Hermes Agent với `image_gen` đã bật và một provider sinh ảnh

> **Chi phí:** mô hình sinh ảnh tính tiền theo lượt và hầu như không có gói
> miễn phí. Một ảnh ngang cho mỗi section, nhân desktop + mobile, nhân số lần
> sinh lại sau feedback. Đặt budget trên tài khoản provider trước khi chạy.

## Kiểm thử

```bash
python3 skills/landing-page-workflow/scripts/selftest
```

## Ghi nhận

Quy trình trong skill này được rút ra từ giáo trình **"#6 — Dựng Landing Page
bằng Hermes Agent"** của Mentor **Đỗ Hoàng Hà** (AI Guru x TiniX). Skill đóng
gói phần quy trình của tài liệu thành thứ agent tự áp dụng được. Bộ skill thiết
kế là của [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill).

## License

MIT
