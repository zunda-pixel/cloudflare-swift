## CloudflareKit

https://developers.cloudflare.com/api

## API List

- [x] Cloudflare Images

### Cloudflare Images

```swift
import ImagesClient

let client = ImageClient(apiToken: "1234567890", accountId: "1234567890")

let uploadedImage = try await client.upload(
  imageURL: URL(string: "https://path/to/image"),
)

print(uploadedImage)
```
