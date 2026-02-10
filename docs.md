## SlugUtils — Phân tích & mô tả dự án

`slug-utils` là một Ruby gem nhỏ gọn cung cấp các tiện ích để **tạo slug “sạch”, thân thiện SEO** từ chuỗi đa ngôn ngữ (ví dụ: tiếng Việt, tiếng Nhật/Trung/Hàn, …) và **đảm bảo tính duy nhất** của slug khi đã có danh sách slug tồn tại.

### 1) Mục tiêu

- **Chuẩn hoá văn bản thành slug** để dùng trong URL (bài viết, sản phẩm, danh mục…).
- Hỗ trợ 2 chế độ:
  - **ASCII-friendly**: loại bỏ dấu tiếng Việt và chỉ giữ `[a-z0-9-]`.
  - **Unicode-friendly**: giữ nguyên ký tự Unicode (giữ dấu tiếng Việt, giữ kanji/kana…).
- Có hàm sinh **slug duy nhất** bằng cách tự động thêm hậu tố `-1`, `-2`, …

### 2) Tính năng chính

- **`SlugUtils.generate(text, keep_accents: false)`**
  - Kiểm tra input: `nil` hoặc toàn khoảng trắng sẽ raise `SlugUtils::InvalidText`.
  - Cắt khoảng trắng 2 đầu và chuyển về chữ thường.
  - Tạo slug theo `keep_accents`:
    - `keep_accents: true`:
      - Thay mọi cụm ký tự không phải chữ/số Unicode bằng dấu `-`.
      - Regex dùng chuẩn Unicode property: `\p{L}` (letters), `\p{N}` (numbers).
    - `keep_accents: false` (mặc định):
      - Chuẩn hoá Unicode sang NFKD rồi encode sang ASCII (loại bỏ dấu/diacritics).
      - Thay mọi cụm ký tự không thuộc `[a-z0-9]` bằng `-`.
  - Loại bỏ dấu `-` ở đầu/cuối.

- **`SlugUtils.generate_unique(text, existing: [], keep_accents: false)`**
  - Sinh `base_slug` bằng `generate`.
  - Nếu `base_slug` đã tồn tại trong `existing`, sẽ thử lần lượt:
    - `base_slug-1`, `base_slug-2`, … cho tới khi không bị trùng.

### 3) Luồng xử lý (tóm tắt thuật toán)

- **Chuẩn hoá**: `strip` → `downcase`
- **Chuyển đổi**:
  - **Unicode mode**: “giữ chữ/số Unicode”, các cụm ký tự khác đổi thành `-`
  - **ASCII mode**: `unicode_normalize(:nfkd)` + `encode("ASCII", replace: "")`, sau đó chỉ giữ `[a-z0-9]`
- **Làm sạch**: gom cụm ký tự phân tách thành `-`, rồi cắt `-` đầu/cuối
- **Unique**: vòng lặp tăng `counter` cho tới khi không trùng

### 4) Ví dụ sử dụng

```ruby
SlugUtils.generate("Học Ruby on Rails 2025!")
# => "hoc-ruby-on-rails-2025"

SlugUtils.generate("Bài viết mới 新しい記事", keep_accents: true)
# => "bài-viết-mới-新しい記事"

SlugUtils.generate("Bài viết mới 新しい記事")
# => "bai-viet-moi"

SlugUtils.generate_unique(
  "Bài viết mới",
  existing: ["bai-viet-moi", "bai-viet-moi-1"]
)
# => "bai-viet-moi-2"
```

### 5) Cấu trúc mã nguồn

- `lib/slug_utils.rb`: module `SlugUtils`, định nghĩa exceptions và 2 API chính `generate`, `generate_unique`.
- `lib/slug_utils/version.rb`: hằng `VERSION`.
- `README.md`: hướng dẫn cài đặt và ví dụ.

### 6) Ghi chú & giới hạn

- Ở chế độ **ASCII** (`keep_accents: false`), các ký tự không phải Latin (như kanji/kana) sẽ bị loại bỏ sau bước encode ASCII → slug có thể ngắn lại đáng kể.
- `generate_unique` hiện kiểm tra trùng bằng `existing.include?`, phù hợp khi `existing` là mảng nhỏ/vừa. Nếu danh sách rất lớn, nên truyền vào một cấu trúc tra cứu nhanh (ví dụ `Set`) hoặc mở rộng API để hỗ trợ.

### RubyGems push
RUBYGEMS_API_KEY=key gem push <.gem>
