flutter emulators --launch Pixel_Fold_API_35

flutter clean
flutter pub get
flutter run --release -d RZ8T31WE39E


flutter run -d emulator-5554





xcrun simctl boot D9D5B234-5723-4CC3-AD42-6F3EC4D3C1B7

flutter run -d D9D5B234-5723-4CC3-AD42-6F3EC4D3C1B7
open -a Simulator

flutter run -d 00008101-001E10420C00801E



ssh kiwana@207.180.249.87
cd /home/kiwana/moto-lens && git pull && cd backend && npm install --production && pm2 restart moto-lens-api