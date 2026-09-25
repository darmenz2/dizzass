"""Stage14 bounded SBC/SBCS and RSC/RSCS extension for original signed timestamp subtraction.
No physical CPU or complete ARM ISA guarantee. Carry means NOT-borrow.
"""
from arm32_difficulty_subset import ARM32Difficulty
from arm32_subset import MASK,signed
class ARM32Freshness(ARM32Difficulty):
    def extra_instruction(self,w,pc):
        if (w & 0x0de00000) in (0x00c00000,0x00e00000) and (w & (1<<25) or (w & 0x90)!=0x90):
            d=(w>>12)&15
            if d==15:raise ValueError('SBC PC destination unsupported')
            a=self.get((w>>16)&15,pc);b,_=self.operand2(w,pc);borrow=int(not self.c)
            if (w & 0x0de00000)==0x00e00000:a,b=b,a
            total=a-b-borrow;y=total & MASK;self.r[d]=y
            if w & (1<<20):
                self.n,self.z,self.c=bool(y>>31),y==0,total>=0
                mathematical=signed(a)-signed(b)-borrow
                self.v=not(-0x80000000<=mathematical<=0x7fffffff)
            return True
        return super().extra_instruction(w,pc)
