function draw_floor_in_axes(axes_h,r_corners,z,do_draw_mask,do_draw_scale_bar)

% deal with args
if ~exist('do_draw_mask','var') || isempty(do_draw_mask) ,
  do_draw_mask=true;
end
if ~exist('do_draw_scale_bar','var') || isempty(do_draw_mask) ,
  do_draw_mask=false;
end

% Sort the corners properly
r_corners=sortrows(r_corners')';  % make sure sorted by x, then y
r_corners(:,3:4)=fliplr(r_corners(:,3:4));  
  % now they're in clockwise order, starting with the one near the origin

% Determine axis limits
padding=0.005;  % m, amount of space to add around corners
xl=[min(r_corners(1,:))-padding max(r_corners(1,:))+padding];
yl=[min(r_corners(2,:))-padding max(r_corners(2,:))+padding];

% set up the main axes
%set_axes_size_fixed_center_explicit(axes_h,[w_axes h_axes])
set(axes_h,'box','on', ...
           'visible','off', ...
           'layer','top', ...
           'dataaspectratio',[1 1 1], ...
           'fontsize',7, ...
           'xlim',100*xl, ...
           'ylim',100*yl);

% draw the mask, which covers the part of the density that extends beyond
% the floor outline
if do_draw_mask,
  xl_expanded=xl+0.01*[-1 +1];
  yl_expanded=yl+0.01*[-1 +1];
  r_mask_part_1= ...
    [xl_expanded(1) xl_expanded(2) xl_expanded(2) xl_expanded(1) xl_expanded(1) ; ...
     yl_expanded(1) yl_expanded(1) yl_expanded(2) yl_expanded(2) yl_expanded(1) ];  % outer loop, counterclockwise
  r_mask_part_2=[r_corners r_corners(:,1)];  % inner loop, clockwise
  r_mask_part_3=[ xl_expanded(1) ; ...
                  yl_expanded(1) ];
  r_mask=[r_mask_part_1 r_mask_part_2 r_mask_part_3];
  patch('parent',axes_h, ...
        'xdata',100*r_mask(1,:), ...
        'ydata',100*r_mask(2,:), ...
        'zdata',100*repmat(z,[1 size(r_mask,2)]), ...
        'facecolor','w', ...
        'edgecolor','none');
  % just to make sure the seam doesn't show
  rc=r_corners(:,1);
  r_lip=[ xl_expanded(1) xl_expanded(1) rc(1) rc(1) xl_expanded(1) ; ...
          yl_expanded(1) rc(2) rc(2) yl_expanded(1) yl_expanded(1) ];
  patch('parent',axes_h, ...
        'xdata',100*r_lip(1,:), ...
        'ydata',100*r_lip(2,:), ...
        'zdata',100*repmat(z,[1 size(r_mask,2)]), ...
        'facecolor','w', ...
        'edgecolor','none');
end

% draw the outline of the floor
line('parent',axes_h, ...
     'xdata',100*[r_corners(1,:) r_corners(1,1)], ...
     'ydata',100*[r_corners(2,:) r_corners(2,1)], ...
     'zdata',100*repmat(z,[1 5])+0.1, ...
     'color','k');
   
% draw the scale bar
if do_draw_scale_bar ,
  x=0.2*xl(1)+0.8*xl(2);
  y=0.9*yl(1)+0.1*yl(2);
  line('parent',axes_h, ...
       'xdata',100*x+[-5 5], ...
       'ydata',100*y*[1 1], ...
       'zdata',100*z*[1 1]+0.1, ...
       'color','k', ...
       'linewidth',2);
end

end
