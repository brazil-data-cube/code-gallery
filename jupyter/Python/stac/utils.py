import rasterio
from rasterio.windows import from_bounds
from rasterio.warp import transform
from rasterio.crs import CRS


def read_raster(cube_item, band, bbox):
    source_crs = CRS.from_string('EPSG:4326')
    
    w, s, e, n = bbox

    uri = cube_item['assets'][band]['href']
    
    with rasterio.open(uri) as src:
        dest_crs = src.crs
        
        t = transform(source_crs, dest_crs, [w, e], [s, n])
        
        
        rst = src.read(1, window=from_bounds(t[0][0], t[1][0], t[0][1], t[1][1], src.transform))

    return rst
