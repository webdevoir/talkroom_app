# frozen_string_literal: true

class Shrine
  module Plugins
    # The `copy` plugin allows copying attachment from one record to another.
    #
    #     plugin :copy
    #
    # It adds a `Attacher#copy` method, which accepts another attacher, and
    # copies the attachment from it:
    #
    #     photo.image_attacher.copy(other_photo.image_attacher)
    #
    # This method will automatically be called when the record is duplicated:
    #
    #     duplicated_photo = photo.dup
    #     duplicated_photo.image #=> #<Shrine::UploadedFile>
    #     duplicated_photo.image != photo.image
    module Copy
      module AttachmentMethods
        def initialize(*)
          super

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize_copy(record)
              super
              @#{@name}_attacher = nil # reload the attacher
              #{@name}_attacher.send(:write, nil) # remove original attachment
              #{@name}_attacher.copy(record.#{@name}_attacher)
            end
          RUBY
        end
      end

      module AttacherMethods
        def copy(attacher)
          options = {action: :copy, move: false}

          copied_attachment = if attacher.cached?
                                cache!(attacher.get, **options)
                              elsif attacher.stored?
                                store!(attacher.get, **options)
                              else
                                nil
                              end

          @old = get
          _set(copied_attachment)
        end
      end
    end

    register_plugin(:copy, Copy)
  end
end
