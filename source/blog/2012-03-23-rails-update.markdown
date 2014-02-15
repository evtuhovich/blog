---
layout: post
title: Обновление на rails3 и проблемы, связанные с этим
date: 2012-03-23 15:19
comments: true
tags: 
- warden
- devise
- rails
---

На «Групоне» мы давно уже переходим с Rails 2.3 на Rails 3.0. На этой неделе перешли — полет нормальный. Но поскольку
сразу переход у нас не получился, то мы переходили по частям. И тут возникла проблема, что в rails3 нужен новый devise (1.5.3),
которому нужен warden (1.1.1). А в rails2 используется devise (1.0.9), которому нужен warden (0.10.7). И вот этот вот
warden стал по-другому сериализовать сессию. А devise стал хранить remember_token в подписанной (signed) cookie. Более
того, из самих рельс пропал класс ActionController::Flash::FlashHash, поэтому при десериализации сессии происходило
неуловимое исключение в Marshal.load.

Все эти проблемы решены были кодом, которые приведен ниже. И еще похожий код был в rails2-ветке, который конвертил
сессию третьих рельс во вторую. Пользуйтесь с осторожностью.

<!-- more -->

```
# config/initializiers/rails3_session.rb
class ActionController::Flash::FlashHash < Hash
end

module ActiveSupport
  class MessageVerifier
    def compat_verify(signed_message)
      raise InvalidSignature if signed_message.blank?

      data, digest = signed_message.split("--")
      if data.present? && digest.present? && secure_compare(digest, generate_digest(data))
        result = Marshal.load(ActiveSupport::Base64.decode64(data))

        if result["flash"].is_a? ActionController::Flash::FlashHash
          result.delete 'flash'
        end

        if result['warden.user.user.key'].is_a?(Array) && result['warden.user.user.key'][0] == User
          klass = result['warden.user.user.key'][0]
          user_id = result['warden.user.user.key'][1]
          begin
            result['warden.user.user.key'] = [klass.to_s, user_id, klass.find(user_id).authenticatable_salt]
          rescue
            result.delete('warden.user.user.key')
          end
        end
        result
      else
        raise InvalidSignature
      end
    end
  end
end

module ActionDispatch
  class Cookies
    class SignedCookieJar
      def [](name)
        if signed_message = @parent_jar[name]
          if name == "_darberry_session"
            @verifier.compat_verify(signed_message)
          elsif name == "remember_user_token"
            if match = signed_message.match(/(\d+)::(.*)/)
              [[match[1].to_i], match[2]]
            end
          else
            @verifier.verify(signed_message)
          end
        end
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end
    end
  end
end
```

Само обновление прошло почти гладко, но мы готовились к нему пару месяцев и делали его постепенно. В целом, после
выкатки, мы просели по производительности раза в полтора. Надеюсь дальнейшее обновление до rails 3.2 и до ruby 1.9.3
нивелирует этот недочет.
