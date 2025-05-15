class BezierCurve{
    vec2 start;
    vec2 control;
    vec2 end;

    BezierCurve(vec2 start, vec2 control, vec2 end){
        this.start = start;
        this.control = control;
        this.end = end;
    }

    vec2 Sample(float t){
        vec2 a = Math::Lerp(start, control, t);
        vec2 b = Math::Lerp(control, end, t);
        return Math::Lerp(a,b,t);
    }

    BezierCurve@ SubDivide(float startT, float endT){
        vec2 newStart = Sample(startT);
        vec2 endStart = Sample(endT);
        
    }
}

class ConfettiStrip{
    vec2 width; //top and bottom widths
    float length;
    BezierCurve@ curve;
    float duration;

    ConfettiStrip(vec2 width, float length, BezierCurve@ curve, float duration){
        this.width = width;
        this.length = length;
        @this.curve = curve;
        this.duration = duration;
    }

    void Update(float deltaTime){

    }
}