class ConfettiStrip{
    array<vec2> vertices;
    float orientation;
    float rotation;
    vec2 position;
    vec2 velocity;
    vec2 gravity;
    float angularDrag;
    float drag;
    vec4 color;

    ConfettiStrip(float width, float height, float skew, float orientation, float rotation, vec2 position, vec2 velocity, vec2 gravity, float angularDrag, float drag, vec4 color){
        vertices = array<vec2>(4);//top left, top right, bottom left, bottom right
        vertices[0] = vec2(-width/2+skew/2, -height/2);
        vertices[1] = vec2(width/2+skew/2, -height/2);
        vertices[2] = vec2(-width/2-skew/2, height/2);
        vertices[3] = vec2(width/2-skew/2, height/2);
        this.orientation = orientation;
        this.rotation = rotation;
        this.position = position;
        this.velocity = velocity;
        this.gravity = gravity;
        this.angularDrag = angularDrag;
        this.drag = drag;
        this.color = color;
    }

    void Update(float deltaTime){
        //if (position.y > Math::Max(vertices[2].x,vertices[2].y)*2+1080) return;
        orientation += rotation*deltaTime;
        position += velocity*deltaTime;
        rotation -= rotation*angularDrag*angularDrag*deltaTime;
        velocity += gravity*deltaTime;
        velocity -= velocity*drag*drag*deltaTime;
    }

    void Render(){
        nvg::ResetTransform();
        nvg::Translate(RefToScreen(position));
        nvg::Rotate(orientation);
        //scale not needed
        nvg::BeginPath();
        nvg::MoveTo(RefToScreen(vertices[0]));
        nvg::LineTo(RefToScreen(vertices[1]));
        nvg::LineTo(RefToScreen(vertices[3]));
        nvg::LineTo(RefToScreen(vertices[2]));
        nvg::LineTo(RefToScreen(vertices[0]));
        nvg::FillColor(color);
        nvg::Fill();
        nvg::ClosePath();

        nvg::ResetTransform();
    }

    float RefToScreen(float x){
        //scale by screen height
        return x * float(Draw::GetHeight())/1080.0;
    }

    vec2 RefToScreen(vec2 x){
        //scale by screen height
        return x * float(Draw::GetHeight())/1080.0;
    }
}