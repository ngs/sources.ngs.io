*** flashview/flashview.py.bk	2008-03-26 15:08:26.000000000 +0900
--- flashview/flashview.py	2008-04-03 03:04:48.000000000 +0900
***************
*** 4,9 ****
--- 4,10 ----
  from zlib import decompressobj
  from cgi import escape as escapeHTML
  import os
+ import random
  from trac.core import *
  from trac.wiki.api import IWikiMacroProvider
***************
*** 63,69 ****
          # args will be null if the macro is called without parenthesis.
          if not content:
              return ''
!         args = content.split(',')
          filespec = args[0]
          # parse filespec argument to get module and id if contained.
--- 64,71 ----
          # args will be null if the macro is called without parenthesis.
          if not content:
              return ''
!
!         args = [x.strip() for x in content.split(',')]
          filespec = args[0]
          # parse filespec argument to get module and id if contained.
***************
*** 124,130 ****
              raw_url = attachment.href(req, format='raw')
              desc = attachment.description
              width, height = swfsize(attachment.open())
!             if len(args) == 3:
                  if args[1][0] == '*':
                      width = int(width * float(args[1][1:]))
                  else:
--- 126,132 ----
              raw_url = attachment.href(req, format='raw')
              desc = attachment.description
              width, height = swfsize(attachment.open())
!             if len(args) >= 3:
                  if args[1][0] == '*':
                      width = int(width * float(args[1][1:]))
                  else:
***************
*** 142,163 ****
                  width = args[1]
                  height = args[2]
          vars = {
              'width': width,
              'height': height,
!             'raw_url': raw_url
              }
          return """
! <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
!         codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab"
!         width="%(width)s" height="%(height)s">
!   <param name="movie" value="%(raw_url)s">
!   <param name="quality" value="low">
!   <param name="play" value="true">
!   <embed src="%(raw_url)s" quality="low" width="%(width)s" height="%(height)s"
!          type="application/x-shockwave-flash"
!          pluginspage="http://www.macromedia.com/go/getflashplayer">
!   </embed>
! </object>
          """ % dict(map(lambda i: (i[0], escapeHTML(str(i[1]))), vars.items()))
--- 144,173 ----
                  width = args[1]
                  height = args[2]
+         flashvars = ''
+         if len(args) == 4 and args[3]:
+             for p in args[3].split('&'):
+                 a = p.split('=')
+                 if(len(a)==2):
+                     flashvars += "so.addVariable('"+a[0]+"','"+a[1]+"'); "
+
          vars = {
              'width': width,
              'height': height,
!             'raw_url': raw_url,
!             'flashvars' : flashvars,
!             'random' : int(random.random() * 1000000)
              }
          return """
! <script type="text/javascript">
! //<![CDATA[
! (function(){
! var rnd = "div%(random)s";
! document.write("<div id='div%(random)s'></div>");
! var so = new SWFObject("%(raw_url)s","div%(random)s","%(width)s","%(height)s","8","#ffffff");
! %(flashvars)s
! so.write("div%(random)s");
! })();
! //]]></script>
          """ % dict(map(lambda i: (i[0], escapeHTML(str(i[1]))), vars.items()))
