(***********************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team    *)
(* <O___,, *        INRIA-Rocquencourt  &  LRI-CNRS-Orsay              *)
(*   \VV/  *************************************************************)
(*    //   *   The HELM Project         /   The EU MoWGLI Project      *)
(*         *   University of Bologna                                   *)
(***********************************************************************)
(*          This file is distributed under the terms of the            *)
(*           GNU Lesser General Public License Version 2.1             *)
(*                                                                     *)
(*                 Copyright (C) 2000-2004, HELM Team.                 *)
(*                       http://helm.cs.unibo.it                       *)
(***********************************************************************)

(* the type token for XML cdata, empty elements and not-empty elements *)
(* Usage:                                                                *)
(*  Str cdata                                                            *)
(*  Empty (element_name, [attrname1, value1 ; ... ; attrnamen, valuen]   *)
(*  NEmpty (element_name, [attrname1, value2 ; ... ; attrnamen, valuen], *)
(*          content                                                      *)
type token = Str of string
           | Empty of string * (string * string) list
	   | NEmpty of string * (string * string) list * token Stream.t
;;

(* currified versions of the constructors make the code more readable *)
let xml_empty name attrs = [< 'Empty(name,attrs) >]
let xml_nempty name attrs content = [< 'NEmpty(name,attrs,content) >]
let xml_cdata str = [< 'Str str >]

(* Usage:                                                                   *)
(*  pp tokens None     pretty prints the output on stdout                   *)
(*  pp tokens (Some filename) pretty prints the output on the file filename *)
let pp strm fn =
 let channel = ref stdout in
 let rec pp_r m =
  parser
    [< 'Str a ; s >] ->
      print_spaces m ;
      fprint_string (a ^ "\n") ;
      pp_r m s
  | [< 'Empty(n,l) ; s >] ->
      print_spaces m ;
      fprint_string ("<" ^ n) ;
      List.iter (function (n,v) -> fprint_string (" " ^ n ^ "=\"" ^ v ^ "\"")) l;
      fprint_string "/>\n" ;
      pp_r m s
  | [< 'NEmpty(n,l,c) ; s >] ->
      print_spaces m ;
      fprint_string ("<" ^ n) ;
      List.iter (function (n,v) -> fprint_string (" " ^ n ^ "=\"" ^ v ^ "\"")) l;
      fprint_string ">\n" ;
      pp_r (m+1) c ;
      print_spaces m ;
      fprint_string ("</" ^ n ^ ">\n") ;
      pp_r m s
  | [< >] -> ()
 and print_spaces m =
  for i = 1 to m do fprint_string "  " done
 and fprint_string str =
  output_string !channel str
 in
  match fn with
     Some filename ->
      let filename = filename ^ ".xml" in
       channel := open_out filename ;
       pp_r 0 strm ;
       close_out !channel ;
       print_string ("\nWriting on file \"" ^ filename ^ "\" was succesful\n");
       flush stdout
   | None ->
       pp_r 0 strm
;;
