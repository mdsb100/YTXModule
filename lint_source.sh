SOURCES='http://gitlab.yintech.net/ytx-ios/ytx-pod-specs.git,master'
IS_SOURCE=1 pod lib lint --sources=$SOURCES --verbose --fail-fast --use-libraries