package particles;

import particles.util.*;
import h2d.SpriteBatch.BatchElement;
import h2d.Tile;

/**
    2D particle
**/
class Particle2D extends BatchElement { 
    /**
        Parent emitter
    **/
    private var _parent : Particles2D;

    public var startPos : ParticleVector = { x: 0.0, y: 0.0 };    
    public var direction : ParticleVector = { x: 0.0, y: 0.0 };    
    public var colorDelta : ParticleColor = { r:0, g:0, b:0, a:0 };    
    public var rotationDelta : Float = 0.0;
    public var radius : Float = 0.0;
    public var radiusDelta : Float = 0.0;
    public var angle : Float = 0.0;
    public var angleDelta : Float = 0.0;
    public var particleSize : Float = 0.0;
    public var particleSizeDelta : Float = 0.0;
    public var radialAcceleration : Float = 0.0;
    public var tangentialAcceleration : Float = 0.0;
    public var timeToLive : Float = 0.0;

    /**
        Reinit particle with data
    **/
    private function Reinit () : Void {
        var ps = _parent;
        timeToLive = Math.max(0.0001, ps.particleLifespan + ps.particleLifespanVariance * MathHelper.rnd1to1());

        startPos.x = ps.sourcePosition.x / ps.particleScaleX;
        startPos.y = ps.sourcePosition.y / ps.particleScaleY;
        
        r = MathHelper.clamp(ps.startColor.r + ps.startColorVariance.r * MathHelper.rnd1to1());
        g = MathHelper.clamp(ps.startColor.g + ps.startColorVariance.g * MathHelper.rnd1to1());
        b = MathHelper.clamp(ps.startColor.b + ps.startColorVariance.b * MathHelper.rnd1to1());
        a = MathHelper.clamp(ps.startColor.a + ps.startColorVariance.a * MathHelper.rnd1to1());
        
        colorDelta = {
            r: (MathHelper.clamp(ps.finishColor.r + ps.finishColorVariance.r * MathHelper.rnd1to1()) - r) / timeToLive,
            g: (MathHelper.clamp(ps.finishColor.g + ps.finishColorVariance.g * MathHelper.rnd1to1()) - g) / timeToLive,
            b: (MathHelper.clamp(ps.finishColor.b + ps.finishColorVariance.b * MathHelper.rnd1to1()) - b) / timeToLive,
            a: (MathHelper.clamp(ps.finishColor.a + ps.finishColorVariance.a * MathHelper.rnd1to1()) - a) / timeToLive,
        };

        particleSize = Math.max(0.0, ps.startParticleSize + ps.startParticleSizeVariance * MathHelper.rnd1to1());

        particleSizeDelta = (Math.max(
            0.0,
            ps.finishParticleSize + ps.finishParticleSizeVariance * MathHelper.rnd1to1()) - particleSize
        ) / timeToLive;

        rotation = ps.rotationStart + ps.rotationStartVariance * MathHelper.rnd1to1();
        rotationDelta = (ps.rotationEnd + ps.rotationEndVariance * MathHelper.rnd1to1() - rotation) / timeToLive;

        var computedAngle = ps.angle + ps.angleVariance * MathHelper.rnd1to1();        

        // For gravity emitter type
        var directionSpeed = ps.speed + ps.speedVariance * MathHelper.rnd1to1();

        x = startPos.x + ps.sourcePositionVariance.x * MathHelper.rnd1to1();
        y = startPos.y + ps.sourcePositionVariance.y * MathHelper.rnd1to1();
        direction.x = Math.cos(computedAngle) * directionSpeed;
        direction.y = Math.sin(computedAngle) * directionSpeed;
        radialAcceleration = ps.radialAcceleration + ps.radialAccelerationVariance * MathHelper.rnd1to1();
        tangentialAcceleration = ps.tangentialAcceleration + ps.tangentialAccelerationVariance * MathHelper.rnd1to1();

        // For radial emitter type
        angle = computedAngle;
        angleDelta = (ps.rotatePerSecond + ps.rotatePerSecondVariance * MathHelper.rnd1to1()) / timeToLive;
        radius = ps.maxRadius + ps.maxRadiusVariance * MathHelper.rnd1to1();
        radiusDelta = (ps.minRadius + ps.minRadiusVariance * MathHelper.rnd1to1() - radius) / timeToLive;        
    }

    /**
        Constructor
    **/
    public function new (t : Tile, parent : Particles2D) {
		super(t);
        _parent = parent;
        Reinit ();        
	}

    /**
        Update particle logic
    **/
    override function update ( dt : Float ) {
        timeToLive -= dt;

        if (timeToLive <= 0.0) {
            Reinit ();
            return true;
        }

        var ps = _parent;

        if (ps.emitterType == Particles2D.EMITTER_TYPE_RADIAL) {
            angle += angleDelta * dt;
            radius += radiusDelta * dt;

            x = startPos.x - Math.cos(angle) * radius;
            y = startPos.y - Math.sin(angle) * radius * ps.yCoordMultiplier;
        } else {
            var radial = { x: 0.0, y: 0.0 };

            x -= startPos.x;
            y = (y - startPos.y) * ps.yCoordMultiplier;

            if (x != 0.0 || y != 0.0) {
                var length = Math.sqrt(x * x + y * y);

                radial.x = x / length;
                radial.y = y / length;
            }

            var tangential = {
                x: - radial.y,
                y: radial.x,
            };

            radial.x *= radialAcceleration;
            radial.y *= radialAcceleration;

            tangential.x *= tangentialAcceleration;
            tangential.y *= tangentialAcceleration;

            direction.x += (radial.x + tangential.x + ps.gravity.x) * dt;
            direction.y += (radial.y + tangential.y + ps.gravity.y) * dt;

            x += direction.x * dt + startPos.x;
            y = (y + direction.y * dt) * ps.yCoordMultiplier + startPos.y;            
        }

        r += colorDelta.r * dt;
        g += colorDelta.g * dt;
        b += colorDelta.b * dt;
        a += colorDelta.a * dt;

        particleSize += particleSizeDelta * dt;
        particleSize = Math.max(0, particleSize);

        rotation += rotationDelta * dt;
        scale = particleSize / t.width * ps.particleScaleSize;        
        return true;
    }
}