.PHONY: all clean web

BOARDS = EltekFlatpack2 EltekFlatpack2-panel
GITREPO = https://github.com/neg2led/flatpack2-adapter
JLCFAB_IGNORE = H1,H2,H3,H4,J1,JP2,J2,PS1

BOARD_FILES = $(addprefix build/, $(BOARDS:=.kicad_pcb))
GERBERS = $(addprefix build/, $(BOARDS:=-gerber.zip))
JLCGERBERS = $(addprefix build/, $(BOARDS:=-jlcpcb.zip))

RADIUS=1

all: $(GERBERS) $(JLCGERBERS) build/web/index.html

build/EltekFlatpack2.kicad_pcb: EltekFlatpack2/EltekFlatpack2.kicad_pcb build
	kikit panelize extractboard -s 120 50 43.75 81  $< $@

build/EltekFlatpack2-panel.kicad_pcb: EltekFlatpack2/EltekFlatpack2.kicad_pcb build
	kikit panelize grid --gridsize 1 2 --space 5 \
			--vtabs 0 --tabsfrom Eco2.User 15 \
			--tabheight 35 --mousebites 0.5 1 -0.25 \
			--railsTb 5 --fiducials 10 2.5 1 2 --tooling 5 2.5 1.5 \
			--radius $(RADIUS) $< $@

%-gerber: %.kicad_pcb
	kikit export gerber $< $@

%-gerber.zip: %-gerber
	zip -j $@ `find $<`

%-jlcpcb: %.kicad_pcb
	kikit fab jlcpcb --no-assembly $^ $@

%-jlcpcb.zip: %-jlcpcb
	zip -j $@ `find $<`

web: build/web/index.html

build:
	mkdir -p build

build/web: build
	mkdir -p build/web

build/web/index.html: build/web $(BOARD_FILES)
	kikit present boardpage \
		-d README.md \
		--name "Eltek Flatpack2 Adapter" \
		-b "Eltek Flatpack2 Adapter" "Single board" build/EltekFlatpack2.kicad_pcb  \
		-b "Eltek Flatpack2 Adapter" "Panel of 2" build/EltekFlatpack2-panel.kicad_pcb  \
		-r "EltekFlatpack2.png" \
		--repository "$(GITREPO)"\
		build/web

clean:
	rm -r build