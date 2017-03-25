/*
Andrew Magnus
amm215
11140881
CMPT 340 - Assignment 5


married_to(person1, person2) % person1 is/was married to person2
child_of(person1, person2) % person1 is a child of person2
male(person) % person is male

female(person) % person is female

Now, consider this partial family tree of the Canadian/British royal family:

                     elizabeth ----- philip
                            |_________|
                                |
                diana ----- charles ----- camilla
                     |________|
          ____________ |______________________________________
         |                            |                        \
   william ---- catherine           harry ---harietta           claire
         |__________|
       ______|______
      |              |
  george         charlotte

2. [10 Points] Represent the relationships in the tree using facts in Prolog, limiting yourself to the four simple predicates listed above.
*/

%-----------FACTS----------
%married_to is a two way relationship, and thus both ways need to be represented, this will make things easier later
married_to(elizabeth, philip).
married_to(philip, elizabeth).
married_to(diana, charles).
married_to(charles, diana).
married_to(camilla, charles).
married_to(charles, camilla).
married_to(william, catherine).
married_to(catherine, william).
%testing
%married_to(harry, harietta).
%arried_to(harietta, harry).
%child_of is a one way relationship, but there is 2 parents
child_of(charles, elizabeth).
child_of(charles, philip).
child_of(harry, diana).
child_of(harry, charles).
child_of(william, charles).
child_of(william, diana).
child_of(george, william).
child_of(george, catherine).
child_of(charlotte, william).
child_of(charlotte, catherine).
%testing
%child_of(claire, charles).
%child_of(claire, diana).

male(philip).
male(charles).
male(william).
male(harry).
male(george).

female(elizabeth).
female(diana).
female(camilla).
female(catherine).
female(charlotte).
%testing
%female(claire).
%
female(harietta).

/*
3. [5 + 5 + 5 + 5 + 10 + 10 + 10 + 10 Points] Write Prolog rules for the following additional relationships (Note: You may need to use not, where not(p) says that p cannot be proved):
*/

%%HELPER FUNCTIONS -- Added to make things a little cleaner and easier to understand
%function to get both the parents of a child
both_Parents(Child, Mum, Dad):-
  child_of(Child, GetMum),
  female(GetMum),
  child_of(Child, GetDad),
  male(GetDad),
  Dad = GetDad,
  Mum = GetMum.

%brothers are male siblings with both the same parents
brother_of(Brother, Sibling):-
  male(Brother),
  both_Parents(Brother, Mum, Dad),
  both_Parents(Sibling, Mum, Dad),
  not(Brother == Sibling).

%sisters are females siblings with both the same parents
sister_of(Sister, Sibling):-
  female(Sister),
  both_Parents(Sister, Mum, Dad),
  both_Parents(Sibling, Mum, Dad),
  not(Sister == Sibling).

sibling_of(Sibling, Person):-
  both_Parents(Person, Mum, Dad),
  both_Parents(Sibling, Mum, Dad),
  not(Person == Sibling).

%person has a sibling, who is married to someone, that someone is your sibling in law
sibling_in_law_of(SiblingInLaw, Person):-
  sibling_of(Sibling, Person),
  married_to(Sibling, SiblingInLaw).
%or your married, and that persons siblings are your siblings in law
sibling_in_law_of(SiblingInLaw, Person):-
  married_to(Person, Spouse),
  sibling_of(Spouse, SiblingInLaw).



  %   a) aunt_of(person1, person2) person1 is aunt of person2
  % aunt is the sister of a parent or the wife of an uncle

  %aunts are the sister of a persons parent
  aunt_of(Aunt, Person):-
    female(Aunt),%aunts are female
    child_of(Person, PersonsParent),%pull out persons parent
    sister_of(Aunt, PersonsParent).% aunts are sisters of a persons parent,
  aunt_of(Aunt, Person):-%aunts are also the wife of ones uncle
    female(Aunt),%aunts are female x
    child_of(Person, PersonsParent),%pull out parent_of
    brother_of(Uncle, PersonsParent), %find parents brothers aka uncles
    married_to(Aunt, Uncle).% parents brothers wives are aunts*/

  %   b) grandchild_of(person1, person2) person1 is the grandchild of person2
  %granchildren are the children of a persons children
  grandchild_of(GrandChild, Person):-
    child_of(PersonsChild, Person), %grab persons kids
    child_of(GrandChild, PersonsChild). % see of those kids have kids

  %   c)  mother_of(person1, person2) person1 mother of person2
  mother_of(Mother, Child):-
    both_Parents(Child, Mother, _).

  %   d) stepmother_of(person1, person2) person1 is the step-mother of person2
  % step-mothers are wives of fathers who are not a childs mother
  stepmother_of(StepMom, Child):-
    both_Parents(Child, BioMom, Daddyo),
    married_to(StepMom, Daddyo),
    not(BioMom == StepMom).

  %   e) nephew_of(person1, person2) person1 is nephew of person 2

  %nephews are the sons of a persons siblings
  nephew_of(Nephew, Person):-
    male(Nephew),
    sibling_of(Sibling, Person),
    child_of(Nephew, Sibling).
  %nephews are also the sons of step siblings (blood siblings SO kids)
  %you can imagine the case where a sibling remaries to someone with previous kids, then child_of(Kid, Sibling) would be false.
  nephew_of(Nephew, Person):-
    male(Nephew),
    both_Parents(Person, Mom, Dad),
    both_Parents(Sibling, Mom, Dad),
    not(Sibling == Person),
    married_to(Sibling, SiblingInLaw),
    not(child_of(Nephew, Sibling)),%only looking for non blood nephews, as we coved blood nephews above
    child_of(Nephew, SiblingInLaw).

  %   f) mother_in_law_of(person1, person2) person1 mother in law of person2
  % mother in law is the mother of a persons spouse
  mother_in_law_of(MotherInLaw, Person):-
    married_to(Person, Spouse),
    both_Parents(Spouse, MotherInLaw, _).

  %   g) brother_in_law_of(person1, person2) person1 is brother in law of person2
  brother_in_law_of(BrotherInLaw, Person):-
    male(BrotherInLaw),
    sibling_in_law_of(BrotherInLaw, Person).

  %   h) ancestor_of(person1, person2) person1 is an ancestor of person2
  ancestor_of(Ancestor, Person):-
    child_of(Person, Ancestor). %base case, if the person is a child of the ancestor, we are done, its true,
  ancestor_of(Ancestor, Person):-
    child_of(Person, Parent),
    ancestor_of(Ancestor, Parent).%otherwise we check if the parents of the person are the children of the ancestor and so on.
