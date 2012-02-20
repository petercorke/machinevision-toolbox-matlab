import sys;
import string;
import re;

list = [];

r = re.compile(r'''%\s*(\w+)\s*(.*)$''');
width = 0;

for fname in sys.argv[1:]:
	if fname.lower() == "contents.m":
		continue;
	f = open(fname);

	hdr = f.readline();
	if (hdr[0] != '%') or (len(hdr) == 0):
		print 'file %s no header' % fname;
	else:
		m = r.match(hdr);
		if m:
			#print '<%s> <%s>' % (m.group(1), m.group(2));
			func = m.group(1);
			desc = m.group(2);
			if len(func) > width:
				width = len(func);
		
			list.append([func.lower(), desc.capitalize()]);
	f.close();

lastletter = [];
print '%Machine Vision Toolbox for Matlab\n%Copyright (c) Peter Corke 2005\n';
for func, desc in list:
	if lastletter != func[0]:
		print '%';
	print '%%%s%s - %s' % (func, ' '*(width-len(func)), desc);
	lastletter = func[0];
