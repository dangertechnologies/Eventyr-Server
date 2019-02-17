class AssetsController < ApplicationController

  # Render images
  def show
    if params[:hash]
      user = User.find_by(avatar_url: params[:hash])

      if user.avatar
        image = Base64.strict_decode64(user.avatar)
        send_data image, type: MimeMagic.by_magic(image).type, disposition: 'inline'
      end
    end
  end
end
