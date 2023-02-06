rm -rf archive.xcarchive Payload *.ipa *.ipa.zip
xcodebuild -project AltStore.xcodeproj \
          -scheme AltStore \
          -sdk iphoneos \
          archive -archivePath ./archive \
          CODE_SIGNING_REQUIRED=NO \
          AD_HOC_CODE_SIGNING_ALLOWED=YES \
          CODE_SIGNING_ALLOWED=NO \
          DEVELOPMENT_TEAM=XYZ0123456 \
          ORG_IDENTIFIER=com.SideStore | tee xcodebuild.log | xcpretty

rm -rf archive.xcarchive/Products/Applications/SideStore.app/Frameworks/AltStoreCore.framework/Frameworks/
ldid -SAltStore/Resources/tempEnt.plist archive.xcarchive/Products/Applications/SideStore.app/SideStore
mkdir Payload
mkdir Payload/SideStore.app
cp -R archive.xcarchive/Products/Applications/SideStore.app/ Payload/SideStore.app/
zip -r SideStore_MDC_11.ipa Payload
