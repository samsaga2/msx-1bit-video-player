#!/bin/env python

from PIL import Image
import glob
import lz77

HEIGHT = 21

def convert_frame(fname, oname):
    with open(oname, "w") as out:
        img = Image.open(fname)
        width, height = img.size
        final = []
        for y in range(HEIGHT):
            for x in range(32):
                for yy in range(8):
                    try:
                        pixels = [img.getpixel((x*8+i,y*8+yy)) for i in range(8)]
                    except IndexError:
                        pixels = [0]*8
                    pixels = ["0" if i==0 else "1" for i in pixels]
                    pixels_byte = int("".join(pixels), 2)
                    final.append(pixels_byte)
        final = lz77.compress(final)
        for b in final:
            out.write("\tdb %d\n" % (b))
        return len(final)

def convert_frames():
    total_size = 0
    with open("out/frames.asm", "w") as out:
        ### convert frames
        page = 3
        page_size = 0x2000
        pages = []
        for fname in sorted(glob.glob("out/*.png")):
            print(fname)

            oname = fname.replace(".png", ".asm")
            lname = oname.replace(".asm", "").replace("out/", "")
            frame_size = convert_frame(fname, oname)

            if page_size < frame_size:
                page += 1
                page_size = 0x2000
                if page == 64:
                    return
            page_size -= frame_size
            total_size += frame_size

            pages.append([lname, page])
            print("page %d" % page)
            out.write("\tpage %d\n" % (page,))
            out.write("%s:\n" % (lname,))
            out.write("\tinclude %s\n" % (oname.replace("out/", ""),))
            out.write("\n")

        print("TOTAL VIDEO SIZE %d bytes" % (total_size,))

        ### frames index
        out.write("\tpage 0\n")
        out.write("data:\n")
        for p in pages:
            out.write("\tdb %d\n" % p[1])
            out.write("\tdw %s\n" % p[0])
        out.write("\tdb 0\n")

convert_frames()
