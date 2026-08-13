# Lỗi thường gặp

Sắp xếp theo tần suất thực tế khi để agent dựng landing page.

## Ảnh vỡ / khung trống (404)

**Nguyên nhân:** agent ghi sai đường dẫn tương đối, hoặc tiến trình sinh ảnh
thất bại giữa chừng mà vẫn viết thẻ `<img>`.

**Đáng chú ý:** lỗi này thường **không** hiện ở `npm run dev`. Vite phục vụ
file từ `public/` và `src/` theo đường dẫn khác bản build, nên tham chiếu sai
vẫn chạy ngon ở dev rồi vỡ ở production.

```bash
python3 scripts/verify-build          # build + dò tham chiếu hỏng
```

**Xử lý:** sửa đường dẫn, hoặc tạm thay bằng `https://placehold.co/600x400`
rồi sinh lại ảnh sau.

## Ảnh bị phóng to, chỉ thấy một góc

`object-cover` dùng nhầm chỗ. Nêu thẳng tên thuộc tính trong feedback và ghi rõ
**không cần sinh lại ảnh** — xem `feedback-prompts.md`.

## Cổng 5173 bị chiếm

Vite tự nhảy sang 5174, 5175, 5176... Đây là tính năng, không phải lỗi. Đọc
đúng cổng trong output. Muốn về mặc định:

```bash
npx kill-port 5173
```

## Trang trắng sau khi build

Nếu mở bằng `file://`: giao thức này chặn ES module, sinh lỗi CORS. Dùng
`npm run preview` (cổng 4173).

Nếu qua preview mà vẫn trắng: mở DevTools Console. Thường là thiếu module —
agent thêm import mà chưa cài gói.

```bash
npm install
git restore package.json package-lock.json   # nếu agent sửa hỏng manifest
```

## Agent báo sửa xong nhưng giao diện không đổi

Cache trình duyệt. Giữ nút reload → **Empty Cache and Hard Reload**.

## Không tìm thấy lệnh `node` / `npm`

Chưa cài Node.js hoặc phiên bản quá cũ. Cài bản LTS tại nodejs.org, mở lại
terminal, kiểm tra `node -v`.

## Không tìm thấy `vite`

Quên `npm install` sau khi clone hoặc sau khi agent sửa `package.json`.

## Skill không kích hoạt

Kiểm tra tên hiển thị thật:

```bash
hermes skills list | grep -E "taste|imagegen|image-to-code"
```

Bẫy phổ biến: cài với `--name taste` nhưng Hermes ưu tiên thuộc tính `name`
trong `SKILL.md` của tác giả, nên tên thật là **`design-taste-frontend`**.
Gọi `taste` trong prompt sẽ không khớp.

## Ảnh toàn placeholder xám

`image_gen` chưa bật, hoặc thiếu API key, hoặc provider hết credit.

```bash
python3 scripts/preflight
hermes tools enable image_gen
```

## Chi phí vượt dự tính

Mô hình sinh ảnh tính tiền theo lượt và hầu như không có gói miễn phí. Một ảnh
ngang riêng cho mỗi section, nhân desktop + mobile, nhân số lần sinh lại sau
feedback — cộng dồn rất nhanh.

Đặt budget trên tài khoản provider trước khi chạy. Trong feedback, ghi rõ
"không sinh lại ảnh" khi vấn đề chỉ là CSS.

## Agent xóa hoặc ghi đè mã nguồn

Ctrl+Z trong editor không cứu được vì agent ghi thẳng vào file. Dùng thang
rollback:

```bash
python3 scripts/checkpoint status                    # xem đã đổi gì
python3 scripts/checkpoint save truoc-khi-rollback   # stash -u
git restore <file>                                   # khôi phục 1 file
python3 scripts/checkpoint rollback                  # về HEAD (tự stash trước)
```

`git reset --hard` xóa vĩnh viễn thay đổi chưa commit và **không** đụng file
untracked. `checkpoint rollback` luôn stash trước nên vẫn lấy lại được bằng
`git stash pop`.

Muốn dọn cả file untracked: `git clean -fd` — xóa vĩnh viễn, cân nhắc kỹ.
