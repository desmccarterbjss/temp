/^\*\*\*.*Mail Centre.*$/{
:top

	s/^[\*]* \([^\*]*\).*$/\1/g

	p

}

/^\*\*\*.*$/{
	
	s/^[\*]* \([^\*]*\).*$/	Work Area Tested:	\1/g
	p
}


/^Mail[ ]*Format(s)[ ]*displayed.*$/{
	s/^Mail[ ]*Format(s)[ ]*displayed:[ ]*\(.*\)$/		Mail Formats Shown: \1/g
	p
}

/^Mail[ ]*Format[ ]*Selected.*$/{
	s/^Mail[ ]*Format[ ]*Selected:[ ]*\(.*\)$/			Mail Selected: \1/g
	p
}

/^Mail[ ]*Class[ ]*displayed.*$/{
	s/^Mail[ ]*Class[ ]*displayed:[ ]*\(.*\)$/				Mail Class Displayed: \1/g
	p
}

/^Mail[ ]*Class[ ]*Selected.*$/{
	s/^Mail[ ]*Class[ ]*Selected:[ ]*\(.*\)$/					Mail Class Selected: \1/g
	p
}

:bottom
