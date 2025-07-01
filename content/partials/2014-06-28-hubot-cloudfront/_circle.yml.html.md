deployment:
  default:
    branch: /deployment\/.*/
    commands:
      - bundle exec middleman sync
      - >
        ./script/hipchat-notify.sh \
          $HIPCHAT_DEPLOYEMNT_ROOM_ID \
          "hubot cloudfront invalidate $CLOUDFRONT_DISTRIBUTION_ID /javascripts/editor-inner.js"
