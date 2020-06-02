package particles;

import particles.util.*;

import h2d.SpriteBatch;
import h2d.Tile;
import h2d.Object;
import h2d.BlendMode;

/**
    Particle emitter
**/
class Particles2D extends Object {
    public static inline var EMITTER_TYPE_GRAVITY : Int = 0;
    public static inline var EMITTER_TYPE_RADIAL : Int = 1;

    public static inline var POSITION_TYPE_FREE : Int = 0;
    public static inline var POSITION_TYPE_RELATIVE : Int = 1;
    public static inline var POSITION_TYPE_GROUPED : Int = 2;

    public var emitterType : Int = 0;
    public var maxParticles : Int = 10;
    public var positionType : Int = 0;
    public var duration : Float = 0.0;
    public var gravity : ParticleVector = { x: 0, y: 0 }
    public var particleLifespan : Float = 0.0;
    public var particleLifespanVariance : Float = 0.0;
    public var speed : Float = 1.0;
    public var speedVariance : Float = 1.0;
    public var sourcePosition : ParticleVector = { x: 0, y: 0 };
    public var sourcePositionVariance : ParticleVector = { x: 0, y: 0 };
    public var angle : Float = 0.0;
    public var angleVariance : Float = 0.0;
    public var startParticleSize : Float = 1.0;
    public var startParticleSizeVariance : Float = 0.0;
    public var finishParticleSize : Float = 0.0;
    public var finishParticleSizeVariance : Float = 0.0;
    public var startColor : ParticleColor = { r:0, g:0, b:0, a:0 };
    public var startColorVariance : ParticleColor = { r:0, g:0, b:0, a:0 };
    public var finishColor : ParticleColor = { r:0, g:0, b:0, a:0 };
    public var finishColorVariance : ParticleColor = { r:0, g:0, b:0, a:0 };
    public var minRadius : Float = 0.0;
    public var minRadiusVariance : Float = 0.0;
    public var maxRadius : Float = 0.0;
    public var maxRadiusVariance : Float = 0.0;
    public var rotationStart : Float = 0.0;
    public var rotationStartVariance : Float = 0.0;
    public var rotationEnd : Float = 0.0;
    public var rotationEndVariance : Float = 0.0;
    public var radialAcceleration : Float = 0.0;
    public var radialAccelerationVariance : Float = 0.0;
    public var tangentialAcceleration : Float = 90.0;
    public var tangentialAccelerationVariance : Float = 0.0;
    public var rotatePerSecond : Float = 0.0;
    public var rotatePerSecondVariance : Float = 0.0;        
    public var active : Bool = false;
    public var restart : Bool = false;
    public var particleScaleX : Float = 1.0;
    public var particleScaleY : Float = 1.0;
    public var particleScaleSize : Float = 1.0;
    public var yCoordMultiplier : Float = 1.0;
    public var emissionFreq : Float = 0.0;

    public var texture : Tile;

    public var blendMode : BlendMode;    
    
    private var emitCounter : Float = 0.0;
    private var elapsedTime : Float = 0.0;

    private var _particleCount : Int;

    /**
        Batch for particles
    **/
    private var _particleBatch : SpriteBatch;

    /**
        Emit one particle
    **/
    private function EmitParticle () : Void {
        var particle = new Particle2D (texture, this);        
        _particleBatch.add (particle);
    }

    /**
        Start emit
    **/
    private function Start () : Void {
        Stop ();        
        _particleBatch = new SpriteBatch (texture);        
        _particleBatch.hasUpdate = true;
        _particleBatch.hasRotationScale = true;
        _particleBatch.blendMode = blendMode;
        addChild (_particleBatch);
        Reinit ();
        active = true;
    }

    /**
        On update
    **/
    private override function sync (ctx : h2d.RenderContext) {
        super.sync (ctx);

        var dt = ctx.elapsedTime;

        if (active && emissionFreq > 0.0) {
            emitCounter += dt;

            while (_particleCount < maxParticles && emitCounter > emissionFreq) {                
                EmitParticle ();
                _particleCount++;
                emitCounter -= emissionFreq;
            }

            if (emitCounter > emissionFreq) {
                emitCounter = (emitCounter % emissionFreq);
            }

            elapsedTime += dt;

            if (duration >= 0.0 && duration < elapsedTime) {
                Stop ();
            }
        }

    }

    /**
        Start emit
    **/
    private function Stop () : Void {
        if (_particleBatch != null) removeChild (_particleBatch);
        active = false;
    }

    /**
        Constructor
    **/
    public function new (?parent : Object) {
        super (parent);                
        texture = Tile.fromColor (0xFF0000, 16, 16);        
    }

    /**
        Reinit emitter
    **/
    public function Reinit () {        
        emitCounter = 0.0;
        elapsedTime = 0.0;
        _particleCount = 0;

        if (emissionFreq <= 0.0) {
            var emissionRate : Float = maxParticles / Math.max(0.0001, particleLifespan);

            if (emissionRate > 0.0) {
                emissionFreq = 1.0 / emissionRate;
            }
        }                
    }

    /**
        Start or stop emit
    **/
    public function Emit (e : Bool) : Void {
        if (e) {
            Start ();
        } else {
            Stop ();
        }        
    }
}
