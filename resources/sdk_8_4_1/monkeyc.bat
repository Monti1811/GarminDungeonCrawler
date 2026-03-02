@echo off

java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -cp "%~dp0monkeybrains.jar"; com.garmin.monkeybrains.Monkeybrains %*
