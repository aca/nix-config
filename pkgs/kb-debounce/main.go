// kb-debounce is an interception-tools filter that removes keyboard chatter
// (switch bounce / double-typing). It reads struct input_event values from
// stdin and writes them to stdout, dropping a key-down that arrives within
// DEBOUNCE_MS of the previous release of the same key.
//
// Pipeline: intercept -g $DEVNODE | kb-debounce | uinput -d $DEVNODE
package main

import (
	"encoding/binary"
	"io"
	"os"
	"strconv"
)

// struct input_event on x86_64:
//   time.tv_sec (8) + time.tv_usec (8) + type (2) + code (2) + value (4) = 24 bytes
const eventSize = 24

const evKey = 0x01

func main() {
	thresholdUs := int64(30) * 1000
	if v := os.Getenv("DEBOUNCE_MS"); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil && n >= 0 {
			thresholdUs = n * 1000
		}
	}

	buf := make([]byte, eventSize)
	lastUp := make(map[uint16]int64)  // last key-up timestamp per code (usec)
	pressed := make(map[uint16]bool)  // whether the last key-down was forwarded

	for {
		if _, err := io.ReadFull(os.Stdin, buf); err != nil {
			return // EOF or read error: device gone, exit cleanly
		}

		typ := binary.LittleEndian.Uint16(buf[16:18])
		code := binary.LittleEndian.Uint16(buf[18:20])
		value := int32(binary.LittleEndian.Uint32(buf[20:24]))

		forward := true
		if typ == evKey {
			switch value {
			case 1: // key down
				if last, ok := lastUp[code]; ok && eventTime(buf)-last <= thresholdUs {
					forward = false // chatter: drop the bounce
				} else {
					pressed[code] = true
				}
			case 0: // key up
				if pressed[code] {
					lastUp[code] = eventTime(buf)
					pressed[code] = false
				} else {
					forward = false // its key-down was dropped, drop the up too
				}
			}
			// value == 2 (autorepeat) and anything else: forward unchanged
		}

		if forward {
			if _, err := os.Stdout.Write(buf); err != nil {
				return
			}
		}
	}
}

func eventTime(buf []byte) int64 {
	sec := int64(binary.LittleEndian.Uint64(buf[0:8]))
	usec := int64(binary.LittleEndian.Uint64(buf[8:16]))
	return sec*1_000_000 + usec
}
