## CloudflareKit

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fzunda-pixel%2Fcloudflare-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/zunda-pixel/cloudflare-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fzunda-pixel%2Fcloudflare-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/zunda-pixel/cloudflare-swift)

https://developers.cloudflare.com/api

## API List

- [x] Cloudflare Images

### Cloudflare Images

```swift
import ImagesClient

let client = ImagesClient(apiToken: "1234567890", accountId: "1234567890")

let uploadedImage = try await client.upload(
  imageURL: URL(string: "https://path/to/image")!,
)

print(uploadedImage)
```
