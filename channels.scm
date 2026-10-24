(cons* (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        (introduction
         (make-channel-introduction
          "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
          (openpgp-fingerprint
           "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
       (channel
        (name 'evilguix)
        (url "https://github.com/MMagueta/EvilGuix")
        (introduction
         (make-channel-introduction
          "419be71729183b5685df0c33d63731cd512edc57"
          (openpgp-fingerprint
           "CE25 E219 59B4 60A8 4BDF  B93F 0AD3 A126 3F9D E73E"))))
       %default-channels)
