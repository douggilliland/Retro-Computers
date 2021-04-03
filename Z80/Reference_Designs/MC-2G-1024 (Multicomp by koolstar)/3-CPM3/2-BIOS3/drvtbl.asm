	public @dtbl
	extrn rhd0,rhd1,rhd2,rrd0
	cseg

@dtbl	dw rhd0,rhd1,rhd2	; drives A:, B:, C:
	dw 0,0,0,0,0,0,0,0,0	; drives D-L absent
	dw rrd0			; drive M:
	dw 0,0,0		; drives N-P absent

	end
