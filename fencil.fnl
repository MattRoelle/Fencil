;; Fencil
;; Interactive spreadsheet application with a Fennel configuration layer
;; Inspired by microsoft excel / google sheets

;; sudo luarocks install lcurses
(local ncurses (require :curses))
(local bit (require :bit))

;; Globals
(var stdscr nil)
(var window nil)
(var active-sheet {})

;; Config
(λ get-config [k default] default)
(local cell-width (get-config :cell-width 10))
(local cell-height (get-config :cell-width 1))
(local input-stack-size (get-config :input-stack-size 128))

;; Spreadsheet operations
(λ load-sheet! []
  (set active-sheet {:data [[1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]
                            [1 2 3 4 5 6 7 8]]
                     :cursor [1 1]
                     :position [1 1]
                     :viewport-size [8 8]}))

(λ get-cell [tbl y x]
  (?. (?. tbl y) x))

;; Rendering 
(λ to-screen-pos [[draw-x draw-y]]
  [(* (- draw-y 1) cell-height)
   (* (- draw-x 1) cell-width)])

(λ draw-cell [cell drawpos]
  (window:attron (bit.bor 1 2 3 4 5 6 7 8))
  (let [[y x] (to-screen-pos drawpos)]
    (stdscr:mvaddstr y x cell)))

(λ draw-sheet [sheet]
  (let [[y x] sheet.position
        [vw vh] sheet.viewport-size]
    (for [draw-x 1 vw] 
      (for [draw-y 1 vh]
        (let [cx (+ -1 x draw-x)
              cy (+ -1 y draw-y)
              cell (get-cell active-sheet.data cy cx)]
          (when cell (draw-cell cell [draw-y draw-x])))))))

;; Main loop
(λ handle-input [input-stack]
  (print (. input-stack 1))
  (match input-stack
    [:h]
    (tset active-sheet.cursor 2 (- (. active-sheet.cursor 2) 1))
    [:l]
    (tset active-sheet.cursor 2 (+ (. active-sheet.cursor 2) 1))))

(λ run []
  (stdscr:clear)
  (draw-sheet active-sheet)
  (let [input-stack []
        [cursor-x cursor-y] (to-screen-pos active-sheet.cursor)]
    (while (not= (?. input-stack 1) -1)
      (table.insert input-stack 1
                    (string.char (stdscr:getch)))
      (while (> (length input-stack) input-stack-size)
        (table.remove input-stack))
      (handle-input input-stack)
      (stdscr:clear)
      (draw-sheet active-sheet)
      (stdscr:move cursor-y cursor-x)
      (stdscr:refresh))))

(λ on-error [err]
  (ncurses.endwin)
  (print "Oops. An error occured")
  (print (debug.traceback err 2))
  (os.exit 2))

(λ main []
  (load-sheet!)
  (set stdscr (ncurses.initscr))
  (set window (ncurses.newwin 25 80 0 0))
  (ncurses.cbreak)
  (ncurses.echo false)
  (ncurses.nl false)
  (run)
  (ncurses.endwin)
  (os.exit 0))

(xpcall main on-error)
