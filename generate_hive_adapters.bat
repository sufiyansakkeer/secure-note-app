@echo off
echo Running build_runner to generate Hive adapters...
flutter pub run build_runner build --delete-conflicting-outputs
echo Done!
pause
