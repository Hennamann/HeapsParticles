package particles.loaders;

import h2d.Tile;
import h2d.BlendMode;
import hxd.res.Resource;

/**
	Particle loader
**/
class ParticleLoader {
    public static function Load(res : Resource, texture : Tile) : Particles2D {
        var partsName = res.name.split(".");
		var ext = partsName[partsName.length - 1];

        switch (ext) {
            case "plist":				
				return PlistParticleLoader.Load(res.entry.getText (), texture);
			case "pex" | "lap":				
				return PexLapParticleLoader.Load(res.entry.getText (), texture);
            default:
                trace('Unsupported extension "${ext}"');
				return null;
        }
    }
	
	/**
		Return blend type
	**/
	public static function GetBlendMode (code : Int) : BlendMode {
		switch(code) {
			case 0: return BlendMode.Add;
			case 1:	return BlendMode.Alpha;
			case 2:	return BlendMode.Multiply;
			case 3:	return BlendMode.None;
			case 4:	return BlendMode.Screen;
			case 5:	return BlendMode.SoftAdd;			
			default:
				trace("BlendMode not found");
				return null;
		}
	}
}
