.PHONY: all clean web

BOARDS = EltekFlatpack2 EltekFlatpack2-panel
GITREPO = https://github.com/neg2led/flatpack2-adapter.git
JLCFAB_IGNORE = H1,H2,H3,H4,J1,JP2,J2,PS1

BOARDSFILES = $(addprefix build/, $(BOARDS:=.kicad_pcb))
SCHFILES = $(addprefix build/, $(BOARDS:=.sch))
GERBERS = $(addprefix build/, $(BOARDS:=-gerber.zip))
JLCGERBERS = $(addprefix build/, $(BOARDS:=-jlcpcb.zip))

RADIUS=0.75

all: $(GERBERS) $(JLCGERBERS) build/web/index.html

build/EltekFlatpack2.kicad_pcb: EltekFlatpack2/EltekFlatpack2.kicad_pcb build
	kikit panelize extractboard -s 125 68.75 43.75 81 $< $@

build/EltekFlatpack2.sch: EltekFlatpack2/EltekFlatpack2.kicad_pcb build
	cp EltekFlatpack2/EltekFlatpack2.sch $@

build/EltekFlatpack2-panel.kicad_pcb: build/EltekFlatpack2.kicad_pcb build
	kikit panelize grid --space 3 --gridsize 2 2 \
        --tabwidth 4 --tabheight 4 --htabs 1 --vtabs 1 \
        --panelsize 135 135 --framecutH \
        --mousebites 1 0.5 0.25 --radius $(RADIUS) $< $@

build/EltekFlatpack2-panel.sch: EltekFlatpack2/EltekFlatpack2.kicad_pcb build
	cp EltekFlatpack2/EltekFlatpack2.sch $@

%-gerber: %.kicad_pcb
	kikit export gerber $< $@

%-gerber.zip: %-gerber
	zip -j $@ `find $<`

%-jlcpcb: %.sch %.kicad_pcb
	kikit fab jlcpcb --assembly --ignore $(JLCFAB_IGNORE) --schematic $^ $@

%-jlcpcb.zip: %-jlcpcb
	zip -j $@ `find $<`

web: build/web/index.html

build:
	mkdir -p build

build/web: build
	mkdir -p build/web

build/web/index.html: build/web $(BOARDSFILES)
	kikit present boardpage \
		-d README.md \
		--name "Eltek Flatpack2 Adapter" \
		-b "Eltek Flatpack2 Adapter" "Single board" build/EltekFlatpack2.kicad_pcb  \
		-b "Eltek Flatpack2 Adapter" "Panel of 3" build/EltekFlatpack2-panel.kicad_pcb  \
		-r "EltekFlatpack2/EltekFlatpack2.png" \
		--repository "$(GITREPO)"\
		build/web

clean:
	rm -r build