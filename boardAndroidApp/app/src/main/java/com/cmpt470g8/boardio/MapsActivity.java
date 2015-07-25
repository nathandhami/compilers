package com.cmpt470g8.boardio;

import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;

import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import java.util.ArrayList;
import java.util.concurrent.ExecutionException;

public class MapsActivity extends LandingPage {

    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    boolean init = false;
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    ArrayList<Event> events = new ArrayList<Event>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_maps);
        setUpMapIfNeeded();
        center();
        loadEvents();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
    }

    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only ever
     * call {@link #setUpMap()} once when {@link #mMap} is not null.
     * <p/>
     * If it isn't installed {@link SupportMapFragment} (and
     * {@link com.google.android.gms.maps.MapView MapView}) will show a prompt for the user to
     * install/update the Google Play services APK on their device.
     * <p/>
     * A user can return to this FragmentActivity after following the prompt and correctly
     * installing/updating/enabling the Google Play services. Since the FragmentActivity may not
     * have been completely destroyed during this process (it is likely that it would only be
     * stopped or paused), {@link #onCreate(Bundle)} may not be called again so we should call this
     * method in {@link #onResume()} to guarantee that it will be called.
     */
    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map))
                    .getMap();
            // Check if we were successful in obtaining the map.
            if (mMap != null) {
                setUpMap();
            }
        }
    }

    /**
     * This is where we can add markers or lines, add listeners or move the camera. In this case, we
     * just add a marker near Africa.
     * <p/>
     * This should only be called once and when we are sure that {@link #mMap} is not null.
     */
    public void center() {
        CameraUpdate center = CameraUpdateFactory.newLatLng(new LatLng(49.2827, -123.1207));
        CameraUpdate zoom= CameraUpdateFactory.zoomTo(9);
        mMap.moveCamera(center);
        mMap.animateCamera(zoom);
    }

    private void setUpMap() {
        final LocationManager locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
        final LocationListener locationListener = new LocationListener() {
            public void onLocationChanged(Location location) {
                // Called when a new location is found by the network location provider.
                CameraUpdate center=
                        CameraUpdateFactory.newLatLng(new LatLng(location.getLatitude(),
                                location.getLongitude()));
                CameraUpdate zoom= CameraUpdateFactory.zoomTo(9);

                mMap.moveCamera(center);
                mMap.animateCamera(zoom);
                mMap.addMarker(new MarkerOptions().position(new LatLng(location.getLatitude(), location.getLongitude())).title("Marker"));
            }

            public void onStatusChanged(String provider, int status, Bundle extras) {}

            public void onProviderEnabled(String provider) {}

            public void onProviderDisabled(String provider) {}
        };

// Register the listener with the Location Manager to receive location updates
        locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            public void run() {
                locationManager.removeUpdates(locationListener);
            }
        }, 10000);


    }

    public void loadEvents(){
        GetEvents tsk = new GetEvents();
        try{
            events = tsk.execute().get();
        } catch(InterruptedException e){
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }

        for (int i=0; i<events.size(); ++i){
            double lat, lng;
            lat = Double.parseDouble(events.get(i).latitude);
            lng = Double.parseDouble(events.get(i).longitude);
            mMap.addMarker(new MarkerOptions().position(new LatLng(lat,lng)).title(events.get(i).name));
        }
    }
}
