class QuadBezierCurve{
    vec2 start;
    vec2 control;
    vec2 end;

    QuadBezierCurve(vec2 start, vec2 control, vec2 end){
        this.start = start;
        this.control = control;
        this.end = end;
    }

    vec2 Sample(float t){
        vec2 a = Math::Lerp(start, control, t);
        vec2 b = Math::Lerp(control, end, t);
        return Math::Lerp(a,b,t);
    }

    QuadBezierCurve@ SubCurve(float startT, float endT){
        vec2 newStart = Sample(startT);
        vec2 newEnd = Sample(endT);
        vec2 a = Math::Lerp(start, control, startT);
        vec2 b = Math::Lerp(control, end, startT);
        vec2 newControl = Math::Lerp(a,b,endT);
        return QuadBezierCurve(newStart, newControl, newEnd);
    }
}