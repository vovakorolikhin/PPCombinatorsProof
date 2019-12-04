Require Import format.
Require Import doc.

Open Scope list_scope.
Require Import ZArith Int.
Require Import Coq.Lists.List.
Require Import String.

Definition cross_general (width: nat) (op: t -> t -> t) (fl1: list t) (fl2: list t) :=
  List.filter 
    (fun f => total_width f <=? width)
    (List.concat (map (fun f => map (op f) fl2) fl1)).

Definition blank_line := (line "")::nil.

(* Construct document from 'string' using 'above' rule *)
Definition constructDoc (s: string) := (of_string s)::nil.

(* Use 'beside' rule for 2 documents. New document ~ n x m *)
Definition besideDoc (width: nat) (fs1: list t) (fs2: list t) := 
  cross_general width add_beside fs1 fs2.

(* Use 'above' rule for 2 documents. New document ~ n x m *)
Definition aboveDoc (width: nat) (fs1: list t) (fs2: list t) := 
   cross_general width add_above fs1 fs2.

(* 'Fill' rule *)
Definition fillDoc (width: nat) (fs1: list t) (fs2: list t) (shift: nat) :=
   cross_general width (fun fs f => add_fill fs f shift) fs1 fs2.

(* Choice operation *)
Definition choiceDoc (fs1: list t) (fs2: list t) := 
    fs1 ++ fs2.

Fixpoint evaluatorTrival (width: nat) (doc: Doc): list t:=
  match doc with
  | Text s     => constructDoc s
  | Indent n d => indentDoc width n (evaluatorTrival width d)
  | Beside a b => besideDoc width (evaluatorTrival width a) (evaluatorTrival width b)
  | Above a b  => aboveDoc width (evaluatorTrival width a) (evaluatorTrival width b)
  | Choice a b => choiceDoc (evaluatorTrival width a) (evaluatorTrival width b)
  | Fill a b n => fillDoc width (evaluatorTrival width a) (evaluatorTrival width b) n
  end.