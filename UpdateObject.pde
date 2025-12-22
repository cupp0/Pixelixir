//we have to accomodate ops that need to update even if they don't provide data to a new scope
//for instance, patching in an interior composite needs to tell the outside world that stuff
//is happening inside it. So we let the update object say either:
//here's a port providing new data to this window, or
//here's an operator that's doing stuff, but not providing new data

class UpdateObject {
 OutPork out;
 Operator op;
 
 UpdateObject(OutPork out_){
   out = out_;
 }
 
 UpdateObject(Operator op_){
   op = op_;
 }
}