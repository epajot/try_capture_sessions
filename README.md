# try_capture_sessions

This project explores and demonstrates the use of `AVFoundation` to read QR codes and to take photos.

Project contains 3 classes that encapsulate the corresponding functionality and hide details of the interaction with AVFoundation.

```
class QRCaptureSession
class PhotoCaptureSession
class QR_and_PhotoCaptureSession
```
Client code, typically a ViewController, instantiates one of these classes, provides the delegate(s) for the session to return the captured items (QR code string or image).

`QR_or_PhotoCaptureViewController` instantiates a `QRCaptureSession` and a `PhotoCaptureSession`, and uses them alternately to perform the QR capture and the photo capture.

 `QR_and_PhotoCaptureViewController` instantiates a `QR_and_PhotoCaptureSession`
