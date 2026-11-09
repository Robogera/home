swayimg.text.visible = false
swayimg.imagelist.order = "mtime"
swayimg.imagelist.reverse = true
swayimg.imagelist.fsmon = true
swayimg.viewer.default_scale = "fit"
swayimg.gallery.aspect = "keep"
swayimg.gallery.thumb_size = 200
swayimg.gallery.selected_scale = 2.0
swayimg.viewer.bind_reset()
swayimg.gallery.bind_reset()
swayimg.gallery.mark_color = 0xffff0000
swayimg.viewer.mark_color = 0xffff0000
swayimg.on_initialized(function()
                           swayimg.mode = "viewer"
                           swayimg.viewer.open("first")
                       end)

swayimg.viewer.on_key("j",
                      function()
                          swayimg.viewer.open("next")
                      end)

swayimg.viewer.on_key("k",
                      function()
                          swayimg.viewer.open("prev")
                      end)
swayimg.gallery.on_key("j",
                      function()
                          swayimg.gallery.select("down")
                      end)

swayimg.gallery.on_key("k",
                      function()
                          swayimg.gallery.select("up")
                      end)
swayimg.gallery.on_key("h",
                      function()
                          swayimg.gallery.select("left")
                      end)
swayimg.gallery.on_key("l",
                      function()
                          swayimg.gallery.select("right")
                      end)


swayimg.viewer.on_key("m",
                      function()
                          swayimg.viewer.mark_image()
                      end)

swayimg.gallery.on_key("m",
                      function()
                          swayimg.gallery.mark_image()
                      end)

swayimg.viewer.on_key("q",
                      function()
                          swayimg.exit()
                      end)

swayimg.gallery.on_key("q",
                      function()
                          swayimg.exit()
                      end)


swayimg.viewer.on_key("x",
                      function()
                           local imagelist = swayimg.imagelist.get()
                           for _, image in ipairs(imagelist) do
                               if image.mark then
                                   os.remove(image.path)
                               end
                           end
                       end)
swayimg.gallery.on_key("x",
                      function()
                           local imagelist = swayimg.imagelist.get()
                           for _, image in ipairs(imagelist) do
                               if image.mark then
                                   os.remove(image.path)
                               end
                           end
                       end)

swayimg.viewer.on_key("g",
                       function()
                           swayimg.mode = "gallery"
                       end)
swayimg.gallery.on_key("g",
                       function()
                           swayimg.mode = "viewer"
                       end)


swayimg.viewer.on_key("y",
                      function()
                          local image = swayimg.viewer.get_image()
                          os.execute("magick " .. image.path .. " PNG:- | wl-copy")
                          swayimg.text.set_status("Copied to clipboard")
                      end)
