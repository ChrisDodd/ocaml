(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)

open Printf;;

let printers = ref []

let locfmt = format_of_string "File \"%s\", line %d, characters %d-%d: %s";;

let field x i =
  let f = Obj.field x i in
  if not (Obj.is_block f) then
    sprintf "%d" (Obj.magic f : int)           (* can also be a char *)
  else if Obj.tag f = Obj.string_tag then
    sprintf "%S" (Obj.magic f : string)
  else if Obj.tag f = Obj.double_tag then
    string_of_float (Obj.magic f : float)
  else
    "_"
;;
let rec other_fields x i =
  if i >= Obj.size x then ""
  else sprintf ", %s%s" (field x i) (other_fields x (i+1))
;;
let fields x =
  match Obj.size x with
  | 0 -> ""
  | 1 -> ""
  | 2 -> sprintf "(%s)" (field x 1)
  | n -> sprintf "(%s%s)" (field x 1) (other_fields x 2)
;;

let to_string x =
  let rec conv = function
    | hd :: tl ->
        (match try hd x with _ -> None with
        | Some s -> s
        | None -> conv tl)
    | [] ->
        match x with
        | Out_of_memory -> "Out of memory"
        | Stack_overflow -> "Stack overflow"
        | Match_failure(file, line, char) ->
            sprintf locfmt file line char (char+5) "Pattern matching failed"
        | Assert_failure(file, line, char) ->
            sprintf locfmt file line char (char+6) "Assertion failed"
        | Undefined_recursive_module(file, line, char) ->
            sprintf locfmt file line char (char+6) "Undefined recursive module"
        | _ ->
            let x = Obj.repr x in
            if Obj.tag x <> 0 then
              (Obj.magic (Obj.field x 0) : string)
            else
              let constructor =
                (Obj.magic (Obj.field (Obj.field x 0) 0) : string) in
              constructor ^ (fields x) in
  conv !printers

let print fct arg =
  try
    fct arg
  with x ->
    eprintf "Uncaught exception: %s\n" (to_string x);
    flush stderr;
    raise x

let catch fct arg =
  try
    fct arg
  with x ->
    flush stdout;
    eprintf "Uncaught exception: %s\n" (to_string x);
    exit 2

type raw_backtrace

external get_raw_backtrace:
  unit -> raw_backtrace = "caml_get_exception_raw_backtrace"

type loc_info =
  | Known_location of bool   (* is_raise *)
                    * string (* filename *)
                    * int    (* line number *)
                    * int    (* start char *)
                    * int    (* end char *)
  | Unknown_location of bool (*is_raise*)

(* to avoid warning *)
let _ = [Known_location (false, "", 0, 0, 0); Unknown_location false]

type backtrace = loc_info array

external convert_raw_backtrace:
  raw_backtrace -> backtrace option = "caml_convert_raw_backtrace"

let format_loc_info pos li =
  let is_raise =
    match li with
    | Known_location(is_raise, _, _, _, _) -> is_raise
    | Unknown_location(is_raise) -> is_raise in
  let info =
    if is_raise then
      if pos = 0 then "Raised at" else "Re-raised at"
    else
      if pos = 0 then "Raised by primitive operation at" else "Called from"
  in
  match li with
  | Known_location(is_raise, filename, lineno, startchar, endchar) ->
      sprintf "%s file \"%s\", line %d, characters %d-%d"
              info filename lineno startchar endchar
  | Unknown_location(is_raise) ->
      sprintf "%s unknown location"
              info

let print_exception_backtrace outchan backtrace =
  match backtrace with
  | None ->
      fprintf outchan
        "(Program not linked with -g, cannot print stack backtrace)\n"
  | Some a ->
      for i = 0 to Array.length a - 1 do
        if a.(i) <> Unknown_location true then
          fprintf outchan "%s\n" (format_loc_info i a.(i))
      done

let print_raw_backtrace outchan raw_backtrace =
  print_exception_backtrace outchan (convert_raw_backtrace raw_backtrace)

(* confusingly named: prints the global current backtrace *)
let print_backtrace outchan =
  print_raw_backtrace outchan (get_raw_backtrace ())

let backtrace_to_string backtrace =
  match backtrace with
  | None ->
     "(Program not linked with -g, cannot print stack backtrace)\n"
  | Some a ->
      let b = Buffer.create 1024 in
      for i = 0 to Array.length a - 1 do
        if a.(i) <> Unknown_location true then
          bprintf b "%s\n" (format_loc_info i a.(i))
      done;
      Buffer.contents b

let raw_backtrace_to_string raw_backtrace =
  backtrace_to_string (convert_raw_backtrace raw_backtrace)

(* confusingly named:
   returns the *string* corresponding to the global current backtrace *)
let get_backtrace () =
  (* we could use the caml_get_exception_backtrace primitive here, but
     we hope to deprecate it so it's better to just compose the
     raw stuff *)
  backtrace_to_string (convert_raw_backtrace (get_raw_backtrace ()))

external record_backtrace: bool -> unit = "caml_record_backtrace"
external backtrace_status: unit -> bool = "caml_backtrace_status"

let register_printer fn =
  printers := fn :: !printers


external get_callstack: int -> raw_backtrace = "caml_get_current_callstack"


let exn_slot x =
  let x = Obj.repr x in
  if Obj.tag x = 0 then Obj.field x 0 else x

let exn_slot_id x =
  let slot = exn_slot x in
  (Obj.obj (Obj.field slot 1) : int)

let exn_slot_name x =
  let slot = exn_slot x in
  (Obj.obj (Obj.field slot 0) : string)


let uncaught_exception_handler = ref None

let set_uncaught_exception_handler fn = uncaught_exception_handler := Some fn

let empty_backtrace : raw_backtrace = Obj.obj (Obj.new_block Obj.abstract_tag 0)

let try_get_raw_backtrace () =
  try
    get_raw_backtrace ()
  with _ (* Out_of_memory? *) ->
    empty_backtrace

let handle_uncaught_exception' exn debugger_in_use =
  try
    (* Get the backtrace now, in case one of the [at_exit] function
       destroys it. *)
    let raw_backtrace =
      if debugger_in_use (* Same test as in [byterun/printexc.c] *) then
        empty_backtrace
      else
        try_get_raw_backtrace ()
    in
    (try Pervasives.do_at_exit () with _ -> ());
    match !uncaught_exception_handler with
    | None ->
        eprintf "Fatal error: exception %s\n" (to_string exn);
        print_raw_backtrace stderr raw_backtrace;
        flush stderr
    | Some handler ->
        try
          handler exn raw_backtrace
        with exn' ->
          let raw_backtrace' = try_get_raw_backtrace () in
          eprintf "Fatal error: exception %s\n" (to_string exn);
          print_raw_backtrace stderr raw_backtrace;
          eprintf "Fatal error in uncaught exception handler: exception %s\n"
            (to_string exn');
          print_raw_backtrace stderr raw_backtrace';
          flush stderr
  with
    | Out_of_memory ->
        prerr_endline
          "Fatal error: out of memory in uncaught exception handler"

(* This function is called by [caml_fatal_uncaught_exception] in
   [byterun/printexc.c] which expects no exception is raised. *)
let handle_uncaught_exception exn debugger_in_use =
  try
    handle_uncaught_exception' exn debugger_in_use
  with _ ->
    (* There is not much we can do at this point *)
    ()

external register_named_value : string -> 'a -> unit
  = "caml_register_named_value"

let () =
  register_named_value "Printexc.handle_uncaught_exception"
    handle_uncaught_exception
