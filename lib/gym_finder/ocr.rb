# frozen_string_literal: true

require 'open3'

module GymFinder
  class Ocr
    def resolve(captcha)
      r, w = IO.pipe
      w.write captcha
      w.close
      r2, w2 = IO.pipe
      Open3.pipeline(
        ['convert', '-', '-resize', '400%', '-threshold', '25%', '-'],
        ['tesseract', 'stdin', 'stdout', '--psm', '8', '-c', 'tessedit_char_whitelist=0123456789', err: File.open("/dev/null", "wb")],
        in: r,
        out: w2
      )
      w2.close
      r2.read.strip
    end
  end
end
